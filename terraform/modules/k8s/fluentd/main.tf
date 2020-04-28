resource "kubernetes_namespace" "fluentd" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

module "docker_credentials" {
  source          = "../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = [kubernetes_namespace.fluentd.metadata[0].annotations.name]
}

resource "helm_release" "fluentd" {
  name       = "fluentd"
  chart      = "odahu-flow-fluentd"
  version    = var.odahu_infra_version
  namespace  = var.namespace
  repository = "odahuflow"
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/helm_values.yaml", {
      docker_repo         = var.docker_repo
      odahu_infra_version = var.odahu_infra_version
    }),
    var.extra_helm_values
  ]

  depends_on = [kubernetes_namespace.fluentd]
}
