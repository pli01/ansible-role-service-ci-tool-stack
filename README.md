# ansible-role-service-ci-tool-stack


This role allows to manage CI Tool stack (gitlab/nexus/jenkins) via docker-compose file and launched via systemd


[![Build Status](https://travis-ci.org/pli01/ansible-role-service-ci-tool-stack.svg?branch=master)](https://travis-ci.org/pli01/ansible-role-service-ci-tool-stack)


Requirements
------------

* docker, docker-compose, ansible 2.2, ansible-lint


Installation
-------------

```sh
make build
( cd build && bash -x deploy.sh )
```

Usage
-----

Variables are documented in [ansible/config/group_vars](ansible/config/group_vars).
Inventory are documented in [ansible/config/inventory](ansible/config/inventory).


