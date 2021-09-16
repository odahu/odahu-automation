#!/usr/bin/env bash

set -e

CLUSTER_NAME=$1
REMAIN_DRIVES=$2

disk_list=$(aws ec2 describe-volumes --filters Name=tag:kubernetes.io/cluster/${CLUSTER_NAME},Values=owned | jq -r '.[]|.[]|.VolumeId')

if [[ "$REMAIN_DRIVES" == "false" ]]; then
    echo "PV drives will be deleted"
    for i in $disk_list
        do
            echo "Deleting $i"
            aws ec2 delete-volume --volume-id "$i"
            echo "$i deleted"
        done
else
    echo "Drives will remain: ${disk_list}"
fi
