#!/bin/bash

BACKUP=$1

docker exec gitlab gitlab-ctl stop unicorn
docker exec gitlab gitlab-ctl stop sidekiq
docker exec gitlab gitlab-ctl reconfigure
docker exec gitlab gitlab-rake gitlab:backup:restore BACKUP=${BACKUP} force=yes
docker exec gitlab gitlab-ctl restart
docker exec gitlab gitlab-rake gitlab:check SANITIZE=true
docker restart gitlab