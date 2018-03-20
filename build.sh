#!/bin/bash
set -e
cd $(dirname $0) || exit 1
# git needed if requirements contains git repo
if [ -f ansible/requirements.yml ] ; then
( cd ansible && ansible-galaxy install -r requirements.yml -p roles -f -vvv )
fi

