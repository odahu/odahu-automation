locals {
  nfs_helm_version = "1.0.0"
  nfs_helm_repo    = "stable"
}

resource "helm_release" "nfs" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "nfs-server"
  chart      = "nfs-server-provisioner"
  version    = local.nfs_helm_version
  namespace  = "kube-system"
  repository = local.nfs_helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/nfs.yaml", {
      image_version = var.nfs_image_tag
      image_repo    = var.nfs_image_repo
      storage_size  = var.configuration.storage_size
    }),
  ]
}
