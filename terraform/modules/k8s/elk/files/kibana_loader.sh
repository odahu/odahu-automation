#!/usr/bin/env bash

set -e

while [[ "$(curl -XGET -s -o /dev/null -w "%{http_code}" "${KIBANA_URL}/app/kibana")" -ne 200 ]]; do
  sleep 1 && echo "Waiting for Kibana..."
done

for datafile in /opt/kibana-import-data/*.ndjson; do
  echo "Processing ${datafile}"
  curl -XPOST -s -w "\n" "${KIBANA_URL}/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" \
    --form "file=@${datafile}"
done
