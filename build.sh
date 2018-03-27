#!/bin/bash
set -e
cd $(dirname $0) || exit 1

ANSIBLE_GALAXY_ARGS=${ANSIBLE_GALAXY_FORCE:+" -f "}

# git needed if requirements contains git repo
if [ -f ansible/requirements.yml ] ; then
( cd ansible && ansible-galaxy install -r requirements.yml -p roles $ANSIBLE_GALAXY_ARGS -vvv )
fi

