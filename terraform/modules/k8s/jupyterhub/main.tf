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

locals {
  ingress_tls_secret_name = "odahu-flow-tls"
}

resource "random_string" "secret" {
  length      = 64
  upper       = false
  lower       = true
  number      = true
  min_numeric = 32
  special     = false
}

resource "kubernetes_namespace" "jupyterhub" {
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
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.jupyterhub_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.jupyterhub]
}

resource "helm_release" "jupyterhub" {
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
      jupyterhub_secret_token = var.jupyterhub_secret_token == "" ? random_string.secret.result : var.jupyterhub_secret_token

      oauth_client_id       = var.oauth_client_id
      oauth_client_secret   = var.oauth_client_secret
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url

      docker_repo = var.docker_repo
    }),
  ]

  depends_on = [
    kubernetes_namespace.jupyterhub,
    kubernetes_secret.jupyterhub_tls
  ]
}
