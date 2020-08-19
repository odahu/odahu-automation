locals {
  nfs_provisioner_version = "v2.3.0"
  nfs_helm_version        = "1.0.0"
}

resource "helm_release" "nfs" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "nfs-server"
  chart      = "nfs-server-provisioner"
  version    = local.nfs_helm_version
  namespace  = "kube-system"
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/nfs.yaml", {
      version      = local.nfs_provisioner_version
      storage_size = var.configuration.storage_size
    }),
  ]
}
