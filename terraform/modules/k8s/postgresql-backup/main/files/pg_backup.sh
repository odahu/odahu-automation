#!/usr/bin/env bash

set -e

if [[ -n "$PG_DATABASES" || -n "$BACKUP_BUCKET" ]]; then
  DATE=$(date +"%F-%H-%M-%S%z")
  RCONFIG="--config /etc/rclone/rclone.conf"
  mkdir -p "/tmp/$DATE"

  for db in $PG_DATABASES; do
    pg_dump --clean "$db" | pigz > /tmp/$DATE/$db.sql.gz
  done

  RCLONE_CMD="rclone -vv $RCONFIG copy /tmp/$DATE pg-backup:$BACKUP_BUCKET/postgresql/$DATE"
  eval "$RCLONE_CMD"

  if [[ -n $BACKUP_RETENTION ]]; then
    RCLONE_CMD="rclone -vv $RCONFIG --min-age $BACKUP_RETENTION delete pg-backup:$BACKUP_BUCKET/postgresql"
    eval "$RCLONE_CMD"
  fi
else
  echo "Error: Required PG_DATABASES or BACKUP_BUCKET isn't provided"
  exit 1
fi
