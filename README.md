# ansible-role-service-ci-tool-stack


This role allows to manage CI Tool stack (gitlab/nexus/jenkins) via docker-compose file and launched via systemd.
each docker-compose stack are associated with each docker host. (all-in-one docker host, or multi-node docker host)

[![Build Status](https://travis-ci.org/pli01/ansible-role-service-ci-tool-stack.svg?branch=master)](https://travis-ci.org/pli01/ansible-role-service-ci-tool-stack)


Requirements
------------

* docker, docker-compose, ansible 2.2, ansible-lint


Installation
-------------

* first, customize your configuration in ansible/config/
* second, build ansible dependencies

```sh
make build
```

* and, deploy your stack

```sh
( cd build && bash -x deploy.sh )
```

Usage
-----

  * Inventory are documented in [ansible/config/inventory](ansible/config/inventory).
  * Variables are documented in [ansible/config/group_vars](ansible/config/group_vars).
  * playbooks are documented in [ansible/playbooks](ansible/playbook).
