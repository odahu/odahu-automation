locals {
  dockerconfigjson = (length(var.docker_username) != 0 && length(var.docker_password) != 0) ? {
    "auths": {
      "${var.docker_repo}" = {
        email    = "admin@odahu.com"
        username = var.docker_username
        password = var.docker_password
        auth     = base64encode(join(":",[var.docker_username, var.docker_password]))
      }
    }
  } : {}
}

resource "kubernetes_namespace" "fluentd" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "kubernetes_secret" "docker_credentials" {
  count = local.dockerconfigjson != {} ? 1 : 0
  metadata {
    name      = "repo-json-key"
    namespace = var.namespace
  }
  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfigjson)
  }
  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.fluentd]
}

resource "null_resource" "set_default_namespace_docker_secret" {
  provisioner "local-exec" {
    command = "kubectl patch serviceaccount -n ${var.namespace} default -p '{\"imagePullSecrets\": [{\"name\": \"repo-json-key\"}]}'"
  }
  depends_on = [kubernetes_namespace.fluentd, kubernetes_secret.docker_credentials]
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
    kubernetes_namespace.fluentd,
    kubernetes_secret.docker_credentials,
    null_resource.set_default_namespace_docker_secret
  ]
}
