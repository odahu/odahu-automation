#!/usr/bin/env bash

set -e

CLUSTER_NAME=$1
REMAIN_DRIVES=$2
CLUSTER_ZONE=$3

disk_list=$(gcloud compute disks list --filter="labels.cluster:${CLUSTER_NAME}" --format="value(selfLink.basename())")

if [[ "$REMAIN_DRIVES" == "false" ]]; then
    for i in $disk_list
        do
            echo $i
            gcloud compute disks delete $i --zone=${CLUSTER_ZONE} --quiet
        done
fi