#!/bin/bash
#
# gitlab restore
#
echo "# Start gitlab restore"
if ! docker-compose exec gitlab /bin/bash -c 'gitlab-ctl status'; then
  echo "ERROR: Gitlab not cleaned"
  exit 1
fi
docker-compose exec gitlab /bin/bash -c '(cd /var/opt/gitlab/backups/ ; backup=$(ls -r1 *_gitlab_backup.tar | head -1) ; gitlab-rake gitlab:backup:restore force=yes BACKUP=$(basename $backup _gitlab_backup.tar) )'
docker-compose exec gitlab /bin/bash -c '(cd /var/opt/gitlab/backups/ ; etc=$(ls -r1 /var/opt/gitlab/backups/etc-gitlab-*.tar | head -1) ; tar -xvf $etc -C / )'
docker-compose exec gitlab /bin/bash -c 'gitlab-ctl restart'
docker-compose exec gitlab /bin/bash -c 'gitlab-rake gitlab:check SANITIZE=true'
echo "# gitlab restore success!"
