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
  deploy_helm_timeout   = "600"
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
  timeout    = local.deploy_helm_timeout
  depends_on = [kubernetes_namespace.vault]
  values = [
    templatefile("${path.module}/templates/vault_values.yaml", {
      vault_version           = local.vault_version
      vault_pvc_storage_class = var.vault_pvc_storage_class
      namespace               = var.namespace
      vault_debug_log_level   = local.vault_debug_log_level
    }),
  ]
}