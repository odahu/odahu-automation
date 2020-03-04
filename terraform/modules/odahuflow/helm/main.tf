locals {
  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"
  vault_tls_secret_name   = "vault-tls"

  default_external_urls = [
    {
      name      = "Documentation",
      url       = "https://docs.odahu.org",
      image_url = "/img/logo/documentation.png"
    },
    {
      name      = "API Gateway",
      url       = "${local.url_schema}://${var.cluster_domain}/swagger/index.html",
      image_url = "/img/logo/swagger.png"
    },
    {
      name      = "ML Metrics",
      url       = "${local.url_schema}://${var.cluster_domain}/mlflow",
      image_url = "/img/logo/mlflow.png"
    },
    {
      name      = "Service Catalog",
      url       = "${local.url_schema}://${var.cluster_domain}/service-catalog/swagger/index.html",
      image_url = "/img/logo/swagger.png"
    },
    {
      name      = "Cluster Monitoring",
      url       = "${local.url_schema}://${var.cluster_domain}/grafana",
      image_url = "/img/logo/grafana.png"
    },
  ]

  default_docker_connection = "docker-ci"

  odahuflow_config = {
    common = {
      external_urls = concat(local.default_external_urls, var.extra_external_urls)
    }
    connection = {
      repository_type = var.vault_enabled ? "vault" : "kubernetes"
      decrypt_token   = var.odahuflow_connection_decrypt_token
      vault           = var.connection_vault_configuration
    }
    operator = {
      oauth_oidc_token_endpoint = var.oauth_oidc_token_endpoint
      client_id                 = var.operator_sa.client_id
      client_secret             = var.operator_sa.client_secret
    }
    deployment = {
      toleration                    = contains(keys(var.node_pools), "model_deployment") ? { Key = var.node_pools["model_deployment"].taints[0].key, Operator = "Equal", Value = var.node_pools["model_deployment"].taints[0].value, Effect = replace(var.node_pools["model_deployment"].taints[0].effect, "/(?i)no_?schedule/", "NoSchedule") } : null
      node_selector                 = contains(keys(var.node_pools), "model_deployment") ? { for key, value in var.node_pools["model_deployment"].labels : key => value } : null
      default_docker_pull_conn_name = local.default_docker_connection
      edge = {
        host = "${local.url_schema}://${var.cluster_domain}"
      }
      namespace = var.odahuflow_deployment_namespace
      security = {
        jwks = var.model_deployment_jws_configuration
      }
    }
    training = {
      toleration        = contains(keys(var.node_pools), "training") ? { Key = var.node_pools["training"].taints[0].key, Operator = "Equal", Value = var.node_pools["training"].taints[0].value, Effect = replace(var.node_pools["training"].taints[0].effect, "/(?i)no_?schedule/", "NoSchedule") } : null
      node_selector     = contains(keys(var.node_pools), "training") ? { for key, value in var.node_pools["training"].labels : key => value } : null
      gpu_toleration    = contains(keys(var.node_pools), "training_gpu") ? { Key = var.node_pools["training_gpu"].taints[0].key, Operator = "Equal", Value = var.node_pools["training_gpu"].taints[0].value, Effect = replace(var.node_pools["training_gpu"].taints[0].effect, "/(?i)no_?schedule/", "NoSchedule") } : null
      gpu_node_selector = contains(keys(var.node_pools), "training_gpu") ? { for key, value in var.node_pools["training_gpu"].labels : key => value } : null
      namespace         = var.odahuflow_training_namespace
      output_connection = "models-output"
      metric_url        = "${local.url_schema}://${var.cluster_domain}/mlflow"
    }
    trainer = {
      oauth_oidc_token_endpoint = var.oauth_oidc_token_endpoint
      client_id                 = var.operator_sa.client_id
      client_secret             = var.operator_sa.client_secret
    }
    packager = {
      oauth_oidc_token_endpoint = var.oauth_oidc_token_endpoint
      client_id                 = var.operator_sa.client_id
      client_secret             = var.operator_sa.client_secret
    }
    packaging = {
      toleration        = contains(keys(var.node_pools), "packaging") ? { Key = var.node_pools["packaging"].taints[0].key, Operator = "Equal", Value = var.node_pools["packaging"].taints[0].value, Effect = replace(var.node_pools["packaging"].taints[0].effect, "/(?i)no_?schedule/", "NoSchedule") } : null
      node_selector     = contains(keys(var.node_pools), "packaging") ? { for key, value in var.node_pools["packaging"].labels : key => value } : null
      namespace         = var.odahuflow_packaging_namespace
      output_connection = "models-output"
    }
  }
  api_vault_volume = {
    name       = "vault-tls"
    mount_path = "/vault/tls"
  }
  api_config = {
    replicas = 2,
    env = var.vault_enabled ? {
      VAULT_CACERT = join("/", [local.api_vault_volume.mount_path, "ca.crt"])
    } : {},
    volumeMounts = var.vault_enabled ? [
      {
        name      = local.api_vault_volume.name,
        mountPath = local.api_vault_volume.mount_path,
      }
    ] : [],
    volumes = var.vault_enabled ? [
      {
        name = local.api_vault_volume.name,
        secret = {
          secretName = local.vault_tls_secret_name
        }
      }
    ] : [],
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
      project         = "odahu-flow"
      istio-injection = "enabled"
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

module "docker_credentials" {
  source             = "../../k8s/docker_auth"
  docker_repo        = var.docker_repo
  docker_username    = var.docker_username
  docker_password    = var.docker_password
  docker_secret_name = var.docker_secret_name
  namespaces = [kubernetes_namespace.odahuflow.metadata[0].annotations.name,
    kubernetes_namespace.odahuflow_training.metadata[0].annotations.name,
    kubernetes_namespace.odahuflow_packaging.metadata[0].annotations.name,
  kubernetes_namespace.odahuflow_deployment.metadata[0].annotations.name]
}

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
  count = var.vault_enabled ? 1 : 0
  metadata {
    name      = local.vault_tls_secret_name
    namespace = var.vault_namespace
  }
  depends_on = [kubernetes_namespace.odahuflow]
}

resource "kubernetes_secret" "odahuflow_vault_tls" {
  count = var.vault_enabled ? 1 : 0
  metadata {
    name      = local.vault_tls_secret_name
    namespace = var.odahuflow_namespace
  }
  data       = data.kubernetes_secret.vault_tls[0].data
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
      docker_secret     = var.docker_secret_name
      odahuflow_version = var.odahuflow_version

      connections           = yamlencode({ connections = var.odahuflow_connections })
      api_configuration     = yamlencode({ api = local.api_config })
      config                = yamlencode({ config = local.odahuflow_config })
      resource_uploader_sa  = var.resource_uploader_sa
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
      oauth_mesh_enabled    = var.oauth_mesh_enabled
    }),
  ]

  depends_on = [
    kubernetes_namespace.odahuflow,
    kubernetes_namespace.odahuflow_training,
    kubernetes_namespace.odahuflow_deployment,
    kubernetes_namespace.odahuflow_packaging,
    kubernetes_secret.odahuflow_vault_tls,
    data.helm_repository.odahuflow
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

      odahuflow_version     = var.odahuflow_version
      resource_uploader_sa  = var.resource_uploader_sa
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
      oauth_mesh_enabled    = var.oauth_mesh_enabled
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
      docker_repo               = var.docker_repo
      packager_version          = var.packager_version
      odahuflow_version         = var.odahuflow_version
      resource_uploader_sa      = var.resource_uploader_sa
      oauth_oidc_issuer_url     = var.oauth_oidc_issuer_url
      oauth_mesh_enabled        = var.oauth_mesh_enabled
      default_docker_connection = local.default_docker_connection
    }),
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}

########################################################
# Install Odahuflow UI
########################################################

resource "helm_release" "odahu_ui" {
  name       = "odahu-ui"
  chart      = "odahu-ui"
  version    = var.odahu_ui_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    templatefile("${path.module}/templates/ui.yaml", {
      docker_repo      = var.docker_repo
      odahu_ui_version = var.odahu_ui_version

      cluster_domain          = var.cluster_domain
      ingress_tls_secret_name = local.ingress_tls_secret_name
      ingress_tls_enabled     = local.ingress_tls_enabled
    }),
  ]

  depends_on = [
    helm_release.odahuflow,
  ]
}