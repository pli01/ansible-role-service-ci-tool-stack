#!/bin/bash
set -e

# Activate configuration playbook of following services
export SERVICE_CI_TOOL_STACK_ENABLE=${SERVICE_CI_TOOL_STACK_ENABLE:-true}

echo "Configuration started"
time ( cd $(dirname $0)/ansible &&
  ansible-playbook -i config -c local -l $(hostname -s) \
     -e action=install \
     playbooks/site.yml -v
)
