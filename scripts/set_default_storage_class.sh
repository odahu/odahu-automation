#!/bin/bash
STORAGE_CLASS=$1

# patch current default storage class to unset `default` status
kubectl patch storageclass "$(kubectl get storageclass  | grep default | awk '{print $1}')" -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
# set new storage class
kubectl patch storageclass "${STORAGE_CLASS}" -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

