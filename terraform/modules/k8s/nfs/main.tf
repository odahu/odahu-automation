locals {
  nfs_provisioner_repo    = "quay.io/kubernetes_incubator/nfs-provisioner"
  nfs_provisioner_version = "v2.3.0"
  nfs_helm_version        = "1.1.1"
  nfs_replicas            = 1
}

resource "helm_release" "nfs" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "nfs-server"
  chart      = "nfs-server-provisioner"
  version    = local.nfs_helm_version
  namespace  = var.namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/nfs.yaml", {
      repo         = local.nfs_provisioner_repo
      version      = local.nfs_provisioner_version
      storage_size = var.configuration.storage_size
      replicas     = local.nfs_replicas
    })
  ]

  depends_on = [var.module_dependency]
}
