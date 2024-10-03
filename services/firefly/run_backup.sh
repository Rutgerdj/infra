#!/bin/bash

BACKUP_DIR=/apps/docker/firefly/backups

script_path=$(realpath "$0")
script_dir=$(dirname $script_path)

$script_dir/backup.sh backup $BACKUP_DIR/$(date '+%F').tar.gz
