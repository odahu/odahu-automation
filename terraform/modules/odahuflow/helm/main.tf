locals {
  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"
  vault_tls_secret_name   = "vault-tls"

  default_external_urls = [
    { name = "Documentation", url = "https://docs.odahu.org" },
    { name = "API Gateway", url = "${local.url_schema}://${var.cluster_domain}/swagger/index.html" },
    { name = "ML Metrics", url = "${local.url_schema}://${var.cluster_domain}/mlflow" },
    var.jupyterhub_enabled ?
      { name = "JupyterHub", url = "${local.url_schema}://${var.cluster_domain}/jupyterhub" } :
      { name = "JupyterLab", url = "${local.url_schema}://${var.cluster_domain}/jupyterlab" },
    { name = "Service Catalog", url = "${local.url_schema}://${var.cluster_domain}/service-catalog/swagger/index.html" },
    { name = "Cluster Monitoring", url = "${local.url_schema}://${var.cluster_domain}/grafana" },
  ]
  odahuflow_config = {
    common = {
      external_urls = concat(local.default_external_urls, var.extra_external_urls)
    }
    connection = {
      repository_type = var.connection_repository_type
      decrypt_token   = var.odahuflow_connection_decrypt_token
      vault           = var.connection_vault_configuration
    }
    deployment = {
      toleration                    = var.model_deployment_nodes.toleration
      node_selector                 = var.model_deployment_nodes.node_selector
      default_docker_pull_conn_name = "docker-ci"
      edge = {
        host = "${local.url_schema}://${var.cluster_domain}"
      }
      namespace = var.odahuflow_deployment_namespace
      security = {
        jwks = var.model_deployment_jws_configuration
      }
    }
    training = {
      toleration        = var.model_training_nodes.toleration
      node_selector     = var.model_training_nodes.node_selector
      namespace         = var.odahuflow_training_namespace
      output_connection = "models-output"
      metric_url        = "${local.url_schema}://${var.cluster_domain}/mlflow"
    }
    packaging = {
      toleration        = var.model_packaging_nodes.toleration
      node_selector     = var.model_packaging_nodes.node_selector
      namespace         = var.odahuflow_packaging_namespace
      output_connection = "models-output"
    }
  }
}

########################################################
# Odahuflow namespaces
########################################################

resource "kubernetes_namespace" "odahuflow" {
  metadata {
    annotations = {
      name = var.odahuflow_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.odahuflow_namespace
  }
}

resource "kubernetes_namespace" "odahuflow_training" {
  metadata {
    annotations = {
      name = var.odahuflow_training_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.odahuflow_training_namespace
  }
}

resource "kubernetes_namespace" "odahuflow_packaging" {
  metadata {
    annotations = {
      name = var.odahuflow_packaging_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.odahuflow_packaging_namespace
  }
}

resource "kubernetes_namespace" "odahuflow_deployment" {
  metadata {
    annotations = {
      name = var.odahuflow_deployment_namespace
    }
    labels = {
      project         = "odahu-flow"
      istio-injection = "enabled"
    }
    name = var.odahuflow_deployment_namespace
  }
}

########################################################
# Odahuflow secrets
########################################################

resource "kubernetes_secret" "tls_odahuflow" {
  count = local.ingress_tls_enabled ? 1 : 0
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.odahuflow_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.odahuflow]
}

data "kubernetes_secret" "vault_tls" {
  metadata {
    name      = local.vault_tls_secret_name
    namespace = var.vault_namespace
  }
  depends_on = [kubernetes_namespace.odahuflow]
}

resource "kubernetes_secret" "odahuflow_vault_tls" {
  metadata {
    name      = local.vault_tls_secret_name
    namespace = var.odahuflow_namespace
  }
  data       = data.kubernetes_secret.vault_tls.data
  depends_on = [kubernetes_namespace.odahuflow]
}

########################################################
# Install Odahuflow chart
########################################################

data "helm_repository" "odahuflow" {
  name = "odahuflow"
  url  = var.helm_repo
}

resource "helm_release" "odahuflow" {
  name       = "odahu-flow"
  chart      = "odahu-flow-core"
  version    = var.odahuflow_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name
  timeout    = 600

  values = [
    templatefile("${path.module}/templates/odahuflow.yaml", {
      cluster_domain          = var.cluster_domain
      ingress_tls_enabled     = local.ingress_tls_enabled
      ingress_tls_secret_name = local.ingress_tls_secret_name

      docker_repo       = var.docker_repo
      odahuflow_version = var.odahuflow_version

      connections = yamlencode({ connections = var.odahuflow_connections })
      config      = yamlencode({ config = local.odahuflow_config })
    }),
  ]

  depends_on = [
    kubernetes_namespace.odahuflow,
    kubernetes_namespace.odahuflow_training,
    kubernetes_namespace.odahuflow_deployment,
    kubernetes_namespace.odahuflow_packaging,
    kubernetes_secret.odahuflow_vault_tls,
    data.helm_repository.odahuflow,
  ]
}

########################################################
# Install Odahuflow-mlflow chart
########################################################

resource "helm_release" "mlflow" {
  name       = "odahu-flow-mlflow"
  chart      = "odahu-flow-mlflow"
  version    = var.mlflow_toolchain_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    templatefile("${path.module}/templates/mlflow.yaml", {
      cluster_domain          = var.cluster_domain
      ingress_tls_secret_name = local.ingress_tls_secret_name
      ingress_tls_enabled     = local.ingress_tls_enabled

      docker_repo              = var.docker_repo
      mlflow_toolchain_version = var.mlflow_toolchain_version

      odahuflow_version = var.odahuflow_version
    }),
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}

########################################################
# Install Odahuflow packagers
########################################################

resource "helm_release" "rest_packagers" {
  name       = "odahu-flow-packagers"
  chart      = "odahu-flow-packagers"
  version    = var.packager_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    templatefile("${path.module}/templates/packagers.yaml", {
      docker_repo       = var.docker_repo
      packager_version  = var.packager_version
      odahuflow_version = var.odahuflow_version
    }),
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}

########################################################
# Install JupyterLab chart
########################################################

resource "helm_release" "jupyterlab" {
  count      = var.jupyterhub_enabled ? 0 : 1
  name       = "odahu-flow-jupyterlab"
  chart      = "odahu-flow-jupyterlab"
  version    = var.jupyterlab_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    templatefile("${path.module}/templates/jupyterlab.yaml", {
      cluster_domain          = var.cluster_domain
      ingress_tls_secret_name = local.ingress_tls_secret_name
      ingress_tls_enabled     = local.ingress_tls_enabled

      docker_repo        = var.docker_repo
      jupyterlab_version = var.jupyterlab_version
    }),
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}
