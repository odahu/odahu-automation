#!/usr/bin/env bash
CLUSTER_NAME=$1
REGION=$2

SG_LIST=$(aws ec2 describe-security-groups --region "${REGION}" --output text --query 'SecurityGroups[*]'.['GroupId'] --filters="Name=tag:aws:eks:cluster-name,Values=${CLUSTER_NAME}")

for sg in ${SG_LIST}; do
  aws ec2 delete-security-group --region "${REGION}" --group-id "$sg" && echo "Deleted ${sg}"
done
