#!/usr/bin/env bash
CLUSTER_NAME=$1

ENI_LIST=$(aws ec2 describe-network-interfaces --filters="Name=group-name,Values=tf-${CLUSTER_NAME}-node" --output text --query 'NetworkInterfaces[*]'.['NetworkInterfaceId'])

for eni in ${ENI_LIST}; do
  aws ec2 delete-network-interface --network-interface-id "$eni"
done
