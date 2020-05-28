resource "kubernetes_storage_class" "sc" {
  metadata {
    name = var.storage_class_name
  }
  parameters          = var.storage_class_settings.parameters
  storage_provisioner = var.storage_class_settings.provisioner
  reclaim_policy      = var.storage_class_settings.reclaim_policy

  allow_volume_expansion = var.storage_class_settings.allow_expansion
  volume_binding_mode    = var.storage_class_settings.binding_mode
}
