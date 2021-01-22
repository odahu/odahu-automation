kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${storage_class_name}
provisioner: kubernetes.io/azure-disk
parameters:
  skuname: Standard_LRS
  kind: managed
  diskEncryptionSetID: "${disk_encryption_set_id}"
