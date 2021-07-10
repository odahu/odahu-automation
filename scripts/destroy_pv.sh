#!/usr/bin/env bash

set -e

CLUSTER_NAME=$1
REMAIN_DRIVES=$2

#disk_list=$(gcloud compute disks list --filter="labels.cluster:${CLUSTER_NAME}" --format="value(selfLink.basename())")
disk_list=$(gcloud compute disks list --filter="name~${CLUSTER_NAME}" --format="value(selfLink.basename())")

if [[ "$REMAIN_DRIVES" == "false" ]]; then
    echo PV drives will be deleted
    for i in $disk_list
        do
            echo Deleting $i
            DRIVE_LOCATION=$(gcloud compute disks list --filter="name:${i}" --format="value(location())")
            gcloud compute disks delete $i --zone=${DRIVE_LOCATION} --quiet
            echo $i deleted
        done
else
    echo "Drives will remain: ${disk_list}"
fi
