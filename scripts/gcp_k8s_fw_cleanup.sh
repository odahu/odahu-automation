#!/usr/bin/env bash

set -e

VPC_NAME=$1
PROJECT_ID=$2

gcloud compute firewall-rules list --filter="name:k8s- AND network:${VPC_NAME}" \
--format='value(name)' --project="${PROJECT_ID}" | \
sed -r 's/(\S+).*/gcloud compute firewall-rules delete \1 --quiet/e'
