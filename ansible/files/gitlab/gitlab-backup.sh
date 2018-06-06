#!/bin/bash
#
# gitlab backup
#
echo "# Start gitlab backup"
if ! docker-compose exec -T gitlab /bin/bash -c 'gitlab-ctl status'; then
  echo "ERROR: Gitlab not ready"
  exit 1
fi
time docker-compose exec -T gitlab /bin/bash -c 'gitlab-rake gitlab:backup:create'
docker-compose exec -T gitlab /bin/bash -c 'umask 0077; tar -cf /var/opt/gitlab/backups/$(date "+etc-gitlab-%s.tar") -C / etc/gitlab'
docker-compose exec -T gitlab /bin/bash -c 'ls -l /var/opt/gitlab/backups/*.tar'
echo "# gitlab backup success!"
exit 0
