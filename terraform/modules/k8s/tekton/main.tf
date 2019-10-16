resource "kubernetes_namespace" "tekton" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "tekton" {
  name       = "tekton"
  chart      = "tekton"
  version    = var.legion_infra_version
  namespace  = var.namespace
  repository = "legion"
  timeout    = "600"
  depends_on = [kubernetes_namespace.tekton]
}