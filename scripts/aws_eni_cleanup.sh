#!/usr/bin/env bash
CLUSTER_NAME=$1
REGION=$2

ENI_LIST=$(aws ec2 describe-network-interfaces --region "${REGION}" --filters="Name=group-name,Values=tf-${CLUSTER_NAME}-node" --output text --query 'NetworkInterfaces[*]'.['NetworkInterfaceId'])

for eni in ${ENI_LIST}; do
  aws ec2 delete-network-interface --region "${REGION}" --network-interface-id "$eni" && echo "Deleted ${eni}"
done
