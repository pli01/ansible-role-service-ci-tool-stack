#!/bin/bash
set -e

# Activate configuration playbook of following services
export SERVICE_CI_TOOL_STACK_ENABLE=${SERVICE_CI_TOOL_STACK_ENABLE:-true}
export SERVICE_CI_NEXUS_STACK_ENABLE=${SERVICE_CI_NEXUS_STACK_ENABLE:-true}
export SERVICE_CI_JENKINS_STACK_ENABLE=${SERVICE_CI_JENKINS_STACK_ENABLE:-true}
export SERVICE_CI_GITLAB_STACK_ENABLE=${SERVICE_CI_GITLAB_STACK_ENABLE:-true}
export SERVICE_CI_FRONT_STACK_ENABLE=${SERVICE_CI_FRONT_STACK_ENABLE:-true}
export SERVICE_CI_ELK_STACK_ENABLE=${SERVICE_CI_ELK_STACK_ENABLE:-true}
export ANSIBLE_DEPLOY_LIMIT=${ANSIBLE_DEPLOY_LIMIT:-$(hostname -s)}
# use connection smart for ssh or local
export ANSIBLE_CONNECTION=${ANSIBLE_CONNECTION:-local}
export ANSIBLE_HOST_KEY_CHECKING=False

echo "Configuration started"
time ( cd $(dirname $0)/ansible &&
  ansible-playbook -i config -c ${ANSIBLE_CONNECTION} -l ${ANSIBLE_DEPLOY_LIMIT} \
     -e action=install \
     playbooks/site.yml --list-tasks --list-hosts  && \
  ansible-playbook -i config -c ${ANSIBLE_CONNECTION} -l ${ANSIBLE_DEPLOY_LIMIT} \
     -e action=install \
     playbooks/site.yml -v

)
