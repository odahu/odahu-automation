resource "kubernetes_namespace" "knative" {
  metadata {
    name = var.knative_namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "knative" {
  name       = "knative"
  chart      = "odahu-flow-knative"
  version    = var.odahu_infra_version
  namespace  = var.knative_namespace
  repository = "odahuflow"
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/knative.yaml", {})
  ]

  depends_on = [
    kubernetes_namespace.knative,
    var.module_dependency
  ]
}
