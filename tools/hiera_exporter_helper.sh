#!/usr/bin/env bash
set -e
set -o xtrace

WORK_DIR=/tmp/work_dir
LEGION_DIR=/opt/legion

mkdir -p "${WORK_DIR}"

cp -r .hiera_keys/* ${WORK_DIR}/
cp -r legion-profiles/* ${WORK_DIR}/
cp tools/hiera_exporter ${WORK_DIR}/

cd ${WORK_DIR}
python3 hiera_exporter \
    --verbose \
    --hiera-config hiera.yaml \
    --vars-template ${LEGION_DIR}/vars_template.yaml \
    --hiera-environment ${CLUSTER_NAME} \
    --hiera-cloud ${CLOUD_PROVIDER} \
    --output-format json \
    --output-file ${LEGION_DIR}/.secrets/cluster_profile.json