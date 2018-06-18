#!/bin/bash
#
# get new openstack token and revoke old one
# and regenerate config file
#  config file = $HOME/openrc
#    export OS_AUTH_URL
#    export OS_TOKEN
#    export OS_PROJECT_ID
#

OPENRC=~/openrc
TOKEN_HEADER=$(mktemp -u /tmp/token.head.XXXXXXXXX)
TOKEN_BODY=$(mktemp -u /tmp/token.body.XXXXXXXXX)

clean(){
  [ -f $TOKEN_BODY ] && rm -rf $TOKEN_BODY
  [ -f $TOKEN_HEADER ] && rm -rf $TOKEN_HEADER
}

trap clean EXIT KILL

for i in curl jq ; do
  bin="$(type -p $i)"
  if [ -z "$bin" ] ; then
    echo "ERROR: $i not found"
    exit 1
  fi
done

if [ -f "$OPENRC" ]; then
   source $OPENRC
else
   echo "WARNING: $OPENRC not found"
fi

# get OS_PROJECT_ID from metadata api
meta_data_json=$(http_proxy="" https_proxy="" /usr/bin/curl --fail -s http://169.254.169.254/openstack/latest/meta_data.json )
[ -z "$OS_TOKEN" ] && export OS_TOKEN="$(echo $meta_data_json | jq -r .meta.os_token)"
[ -z "$OS_PROJECT_ID" ] && export OS_PROJECT_ID="$(echo $meta_data_json | jq -r .meta.os_project_id)"

if [ -z "$OS_AUTH_URL" -o -z "$OS_TOKEN" -o -z "$OS_PROJECT_ID" ] ; then
   echo "ERROR: OS_AUTH_URL, OS_TOKEN or OS_PROJECT_ID empty"
   exit 1
fi

[ -f $TOKEN_BODY ] && rm -rf $TOKEN_BODY
[ -f $TOKEN_HEADER ] && rm -rf $TOKEN_HEADER

try=2
until [ $try -eq 0 ] ; do
  echo "# new OS_TOKEN ($try): get"
  JSON_TOKEN='{ "auth": { "identity": { "methods": ["token"], "token": { "id": "'$OS_TOKEN'" } }, "scope": { "project": { "id": "'$OS_PROJECT_ID'" } } } }'
  curl -s --fail -o $TOKEN_BODY -D $TOKEN_HEADER -X POST -H "Content-Type: application/json" -d "$JSON_TOKEN" $OS_AUTH_URL/auth/tokens 2>&1
  ret=$?
  if [ $ret -gt 0 ] || [ ! -s "$TOKEN_HEADER" ]; then
    meta_data_json=$(http_proxy="" https_proxy="" /usr/bin/curl --fail -s http://169.254.169.254/openstack/latest/meta_data.json )
    export OS_TOKEN="$(echo $meta_data_json | jq -r .meta.os_token)"
    export OS_PROJECT_ID="$(echo $meta_data_json | jq -r .meta.os_project_id)"
    try=$(( try - 1 ))
  else
    try=0
  fi
done

if [ $ret -gt 0 ] || [ ! -s "$TOKEN_HEADER" ]; then
  [ -f $TOKEN_BODY ] && ls -alrt $TOKEN_BODY
  [ -f $TOKEN_HEADER ] && ls -alrt $TOKEN_HEADER
  echo "Failed to renew OS_TOKEN: $OS_TOKEN for $OS_PROJECT_ID"
  echo "renew result: $ret"
  exit 1
fi

echo "# new OS_TOKEN: generated"
NEW_OS_TOKEN=$(awk ' /^X-Subject-Token:/ { print $2 } ' $TOKEN_HEADER | sed -e 's/\r$//g')
if [ -z "$NEW_OS_TOKEN" ]  ;then
  echo "Failed OS_TOKEN: $OS_TOKEN expired"
  exit 1
fi
if [ -s "$TOKEN_BODY" ] ; then
        TOKEN_EXPIRES_AT=$(jq  '.[].expires_at' $TOKEN_BODY)
        TOKEN_ISSUED_AT=$(jq  '.[].issued_at' $TOKEN_BODY)
fi

echo "# new OS_TOKEN: save TOKEN_ISSUED_AT:$TOKEN_ISSUED_AT TOKEN_EXPIRES_AT:$TOKEN_EXPIRES_AT"
cat <<EOF > $OPENRC.new
export OS_TOKEN="$NEW_OS_TOKEN"
export OS_PROJECT_ID="$OS_PROJECT_ID"
export OS_AUTH_URL="$OS_AUTH_URL"
EOF
cp $OPENRC $OPENRC.old
mv $OPENRC.new $OPENRC

echo "# old OS_TOKEN: revoke"
curl -s --fail -X DELETE -H "Content-Type: application/json" \
  -H "X-Auth-Token: $OS_TOKEN" \
  -H "X-Subject-Token: $OS_TOKEN" \
$OS_AUTH_URL/auth/tokens

