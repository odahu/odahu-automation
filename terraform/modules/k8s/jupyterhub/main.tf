locals {
  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "jupyterhub-tls"

  ingress_common = {
    enabled = true
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
    hosts = [ var.cluster_domain ]
  }

  ingress_tls = local.ingress_tls_enabled ? {
    tls = [
      { secretName = local.ingress_tls_secret_name, hosts = [ var.cluster_domain ] }
    ]
  } : {}

  ingress_config = merge(local.ingress_common, local.ingress_tls)
}

########################################################
# Install Jupyterhub flow chart
########################################################

resource "null_resource" "add_helm_jupyterhub_repository" {
  count    = var.jupyterhub_enabled ? 1 : 0
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add jupyterhub ${var.jupyterhub_helm_repo}"
  }
}

resource "random_string" "secret" {
  count       = var.jupyterhub_enabled ? 1 : 0
  length      = 64
  upper       = false
  lower       = true
  number      = true
  min_numeric = 32
  special     = false
}

resource "kubernetes_namespace" "jupyterhub" {
  count = var.jupyterhub_enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.jupyterhub_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.jupyterhub_namespace
  }
  depends_on = [null_resource.add_helm_jupyterhub_repository[0]]
}

resource "kubernetes_secret" "jupyterhub_tls" {
  count = var.jupyterhub_enabled && local.ingress_tls_enabled ? 1 : 0
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.jupyterhub_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.jupyterhub[0]]
}

resource "helm_release" "jupyterhub" {
  count      = var.jupyterhub_enabled ? 1 : 0
  name       = "jupyterhub"
  chart      = "jupyterhub/jupyterhub"
  version    = var.jupyterhub_chart_version
  namespace  = var.jupyterhub_namespace
  repository = "jupyterhub"
  timeout    = "900"

  values = [
    templatefile("${path.module}/templates/jupyterhub.yaml", {
      cluster_domain          = var.cluster_domain
      ingress_tls_secret_name = local.ingress_tls_secret_name
      jupyterhub_secret_token = var.jupyterhub_secret_token == "" ? random_string.secret[0].result : var.jupyterhub_secret_token

      oauth_client_id       = var.oauth_client_id
      oauth_client_secret   = var.oauth_client_secret
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url

      ingress = yamlencode({ ingress = local.ingress_config })

      version     = var.docker_tag
      docker_repo = var.docker_repo
    }),
  ]

  depends_on = [
    kubernetes_namespace.jupyterhub[0],
    kubernetes_secret.jupyterhub_tls[0]
  ]
}
