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

resource "helm_release" "fluentd-daemonset" {
  name       = "logging-operator"
  chart      = local.chart
  version    = local.helm_version
  namespace  = "logging"
  repository = local.helm_repo

  values = [
    templatefile("${path.module}/templates/helm_values.yaml", {
      docker_repo         = var.docker_repo
      odahu_infra_version = "1.2.0-b1587551770858"
#var.odahu_infra_version
    }),
    var.extra_helm_values
  ]

  depends_on = [kubernetes_namespace.fluentd]
}
