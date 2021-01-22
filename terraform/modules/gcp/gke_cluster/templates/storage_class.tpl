apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: ${storage_class_name}
provisioner: pd.csi.storage.gke.io
volumeBindingMode: "WaitForFirstConsumer"
allowVolumeExpansion: true
parameters:
  type: ${storage_type}
  disk-encryption-kms-key: ${kms_key_id}
