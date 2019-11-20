resource "kubernetes_namespace" "fluentd" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "fluentd" {
  name       = "fluentd"
  chart      = "odahu-flow-fluentd"
  version    = var.odahu_infra_version
  namespace  = var.namespace
  repository = "odahuflow"

  values = [
    templatefile("${path.module}/templates/helm_values.yaml", {
      docker_repo         = var.docker_repo
      odahu_infra_version = var.odahu_infra_version
    }),
    var.extra_helm_values
  ]

  depends_on = [
    kubernetes_namespace.fluentd
  ]
}