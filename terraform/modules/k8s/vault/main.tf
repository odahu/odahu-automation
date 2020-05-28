resource "kubernetes_namespace" "vault" {
  count = var.configuration.enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

locals {
  vault_helm_version    = "0.8.3"
  vault_version         = "1.2.3"
  vault_helm_repo       = "banzaicloud-stable"
  vault_debug_log_level = "true"
  vault_pvc_name        = "vault-file"
}

resource "helm_release" "vault" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "vault"
  chart      = "${local.vault_helm_repo}/vault"
  version    = local.vault_helm_version
  namespace  = var.namespace
  repository = local.vault_helm_repo
  timeout    = var.helm_timeout
  depends_on = [kubernetes_namespace.vault]
  values = [
    templatefile("${path.module}/templates/values.yaml", {
      vault_version         = local.vault_version
      storage_class         = var.storage_class
      storage_size          = var.storage_size
      namespace             = var.namespace
      vault_debug_log_level = local.vault_debug_log_level
    }),
  ]
}
