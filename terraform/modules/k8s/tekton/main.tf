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
  chart      = "odahu-flow-tekton"
  version    = var.odahu_infra_version
  namespace  = var.namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout
  depends_on = [kubernetes_namespace.tekton]
}
