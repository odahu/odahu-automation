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
  version    = var.odahu_infra_version
  namespace  = var.namespace
  repository = "odahuflow"
  timeout    = "600"
  depends_on = [kubernetes_namespace.tekton]
}