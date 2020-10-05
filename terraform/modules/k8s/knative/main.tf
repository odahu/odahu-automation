resource "kubernetes_namespace" "knative" {
  metadata {
    name = var.knative_namespace
    labels = {
      istio-injection = "enabled"
    }
  }
  timeouts {
    delete = "15m"
  }
}

resource "helm_release" "knative" {
  name       = "knative"
  chart      = "odahu-flow-knative"
  version    = var.odahu_infra_version
  namespace  = var.knative_namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/knative.yaml", {})
  ]

  depends_on = [
    kubernetes_namespace.knative,
    var.module_dependency
  ]
}
