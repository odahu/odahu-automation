#!/usr/bin/env bash
CLUSTER_NAME=$1
REGION=$2

ENI_LIST=$(aws --region=${REGION} ec2 describe-network-interfaces --filters="Name=group-name,Values=tf-${CLUSTER_NAME}-node" | jq -r '.NetworkInterfaces | .[] | .NetworkInterfaceId')

for eni in ${ENI_LIST}; do
  aws --region=${REGION} ec2 delete-network-interface --network-interface-id $eni
done
