apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: ${storage_class_name}
provisioner: kubernetes.io/aws-ebs
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: ${storage_type}
  fstype: ${fs_type}
  encrypted: "true"
  kmsKeyId: ${kms_key_arn}
