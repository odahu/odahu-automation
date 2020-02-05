#!/bin/bash
SECRET_NAME=$1
NS=$2
SA_LIST=$3
for SA in $SA_LIST
do
  kubectl patch serviceaccount -n $NS $SA -p "{\"imagePullSecrets\": [{\"name\": \"${SECRET_NAME}\"}]}"
done
