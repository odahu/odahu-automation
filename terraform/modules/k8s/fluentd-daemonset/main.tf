locals {
  sa_annotations = length(try(var.extra_helm_values, "sa_annotations", {})) == 0 ? {} : { "serviceAccount" = { "annotations" = var.extra_helm_values.sa_annotations } }

  fluentd_daemonset_values = {
    "extraAnnotations" = var.extra_helm_values.annotations
    "extraEnvs"        = var.extra_helm_values.envs
    "extraSecrets"     = var.extra_helm_values.secrets
    "configData" = {
      "cloud-config.inc"   = var.extra_helm_values.config
      "filters-config.inc" = templatefile("${path.module}/templates/fluentd_filters.tpl", {})
      "source-config.inc"  = templatefile("${path.module}/templates/fluentd_sources.tpl", {})
      "fluent.conf" = templatefile(
        "${path.module}/templates/fluentd_main.tpl", { pod_prefixes = var.pod_prefixes }
      )
    }
  }
}

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
  name       = "fluentd"
  chart      = "odahu-flow-fluentd-daemonset"
  version    = var.odahu_infra_version
  namespace  = var.namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/helm_values.yaml", {
      docker_repo         = var.docker_repo
      odahu_infra_version = var.odahu_infra_version

      fluentd_daemonset_values = yamlencode({ "fluentd" = local.fluentd_daemonset_values })
      sa_annotations           = yamlencode(local.sa_annotations)
    })
  ]

  depends_on = [kubernetes_namespace.fluentd]
}
