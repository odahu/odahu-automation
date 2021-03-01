locals {
  pg_odahu_credentials_plain = ((length(var.pgsql_odahu.secret_namespace) != 0) && (length(var.pgsql_odahu.secret_name) != 0)) ? 0 : 1

  pg_odahu_username = local.pg_odahu_credentials_plain == 1 ? var.pgsql_odahu.db_password : lookup(lookup(data.kubernetes_secret.pg_odahu[0], "data", {}), "username", "")
  pg_odahu_password = local.pg_odahu_credentials_plain == 1 ? var.pgsql_odahu.db_user : lookup(lookup(data.kubernetes_secret.pg_odahu[0], "data", {}), "password", "")

  pg_mlflow_credentials_plain = ((length(var.pgsql_mlflow.secret_namespace) != 0) && (length(var.pgsql_mlflow.secret_name) != 0)) ? 0 : 1

  pg_mlflow_username = local.pg_mlflow_credentials_plain == 1 ? var.pgsql_mlflow.db_password : lookup(lookup(data.kubernetes_secret.pg_mlflow[0], "data", {}), "username", "")
  pg_mlflow_password = local.pg_mlflow_credentials_plain == 1 ? var.pgsql_mlflow.db_user : lookup(lookup(data.kubernetes_secret.pg_mlflow[0], "data", {}), "password", "")

  training_node_pools     = flatten([for k, v in var.node_pools : [for i in try(v["taints"], []) : k if i.value == "training"]])
  gpu_training_node_pools = flatten([for k, v in var.node_pools : [for i in try(v["taints"], []) : k if i.value == "training-gpu"]])
  deployment_node_pools   = flatten([for k, v in var.node_pools : [for i in try(v["taints"], []) : k if i.value == "deployment"]])
  packaging_node_pools    = flatten([for k, v in var.node_pools : [for i in try(v["taints"], []) : k if i.value == "packaging"]])

  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"
  vault_tls_secret_name   = "vault-tls"

  default_external_urls = [
    {
      name     = "Docs",
      url      = "https://docs.odahu.org",
      imageUrl = "/img/logo/documentation.png"
    },
    {
      name     = "API Gateway",
      url      = "${local.url_schema}://${var.cluster_domain}/swagger/index.html",
      imageUrl = "/img/logo/swagger.png"
    },
    {
      name     = "ML Metrics",
      url      = "${local.url_schema}://${var.cluster_domain}/mlflow",
      imageUrl = "/img/logo/mlflow.png"
    },
    {
      name     = "Service Catalog",
      url      = "${local.url_schema}://${var.cluster_domain}/service-catalog/catalog/index.html",
      imageUrl = "/img/logo/swagger.png"
    },
    {
      name     = "Cluster Monitoring",
      url      = "${local.url_schema}://${var.cluster_domain}/grafana",
      imageUrl = "/img/logo/grafana.png"
    },
  ]

  default_model_docker_connection_id = "docker-ci"


  # Endpoint documentation https://oauth2-proxy.github.io/oauth2-proxy/endpoints#sign-out
  signout_url_redirect = format(
    "%s://%s/oauth2/sign_out?rd=%s",
    local.url_schema,
    var.cluster_domain,
    urlencode("${local.url_schema}://${var.cluster_domain}/dashboard")
  )

  odahu_db_connection_string  = var.pgsql_odahu.enabled ? "postgresql://${local.pg_odahu_username}:${local.pg_odahu_password}@${var.pgsql_odahu.db_host}/${var.pgsql_odahu.db_name}" : null
  mlflow_db_connection_string = var.pgsql_mlflow.enabled ? "postgresql://${local.pg_mlflow_username}:${local.pg_mlflow_password}@${var.pgsql_mlflow.db_host}/${var.pgsql_mlflow.db_name}" : null
  mlflow_artifact_root        = var.mlflow_artifact_root

  odahuflow_config = {
    common = {
      version                  = var.odahuflow_version
      externalUrls             = concat(local.default_external_urls, var.extra_external_urls)
      databaseConnectionString = local.odahu_db_connection_string
      oauthOidcTokenEndpoint   = var.oauth_oidc_token_endpoint
    }
    users = {
      # Keycloak end_session_endpoint redirect
      signOutUrl = format(
        "%s?redirect_uri=%s",
        var.oauth_oidc_signout_endpoint,
        urlencode(local.signout_url_redirect)
      )
    }
    connection = {
      repositoryType = var.vault_enabled ? "vault" : "kubernetes"
      vault          = var.connection_vault_configuration
    }
    operator = {
      auth = {
        oauthOidcTokenEndpoint = var.oauth_oidc_token_endpoint
        clientId               = var.operator_sa.client_id
        clientSecret           = var.operator_sa.client_secret
      }
    }
    deployment = {
      tolerations = length(local.deployment_node_pools) != 0 ? distinct(flatten([
        for nodepool in local.deployment_node_pools : [
          for taint in lookup(var.node_pools[nodepool], "taints", []) : {
            Key      = taint.key
            Operator = "Equal"
            Value    = taint.value
            Effect   = replace(taint.effect, "/(?i)no_?schedule/", "NoSchedule")
      }]])) : null

      nodePools = length(local.deployment_node_pools) != 0 ? [
        for k, v in var.node_pools :
        merge(
          { nodeSelector = { for key, value in v.labels : key => value } },
          { tags = compact(distinct(concat(
            try(v["tags"], []),
          [k, try(v["machine_type"], ""), try(v["preemptible"], "") == true ? "preemptible" : ""]))) }
        )
        if contains(local.deployment_node_pools, k)
      ] : null

      defaultDockerPullConnName = local.default_model_docker_connection_id

      namespace = var.odahuflow_deployment_namespace

      edge = {
        host = "${local.url_schema}://${var.cluster_domain}"
      }

      security = {
        jwks = var.model_deployment_jws_configuration
      }
    }
    training = {
      tolerations = length(local.training_node_pools) != 0 ? distinct(flatten([
        for nodepool in local.training_node_pools : [
          for taint in lookup(var.node_pools[nodepool], "taints", []) : {
            Key      = taint.key
            Operator = "Equal"
            Value    = taint.value
            Effect   = replace(taint.effect, "/(?i)no_?schedule/", "NoSchedule")
      }]])) : null

      nodePools = length(local.training_node_pools) != 0 ? [
        for k, v in var.node_pools :
        merge(
          { nodeSelector = { for key, value in v.labels : key => value } },
          { tags = compact(distinct(concat(
            try(v["tags"], []),
            [k, try(v["machine_type"], ""), try(v["preemptible"], "") == true ? "preemptible" : ""]
          ))) }
        )
        if contains(local.training_node_pools, k)
      ] : null

      gpuTolerations = length(local.gpu_training_node_pools) != 0 ? distinct(flatten([
        for nodepool in local.gpu_training_node_pools : [
          for taint in lookup(var.node_pools[nodepool], "taints", []) : {
            Key      = taint.key
            Operator = "Equal"
            Value    = taint.value
            Effect   = replace(taint.effect, "/(?i)no_?schedule/", "NoSchedule")
      }]])) : null

      gpuNodePools = length(local.gpu_training_node_pools) != 0 ? [
        for k, v in var.node_pools :
        merge(
          { nodeSelector = { for key, value in v.labels : key => value } },
          { tags = compact(distinct(concat(
            try(v["tags"], []),
            [k, "gpu", try(v["machine_type"], ""), try(v["preemptible"], "") == true ? "preemptible" : ""]
          ))) }
        )
        if contains(local.gpu_training_node_pools, k)
      ] : null

      namespace          = var.odahuflow_training_namespace
      outputConnectionID = "models-output"
      metricUrl          = "${local.url_schema}://${var.cluster_domain}/mlflow"
      timeout            = length(var.odahuflow_training_timeout) == 0 ? null : var.odahuflow_training_timeout

      toolchainIntegrationRepositoryType = var.pgsql_odahu.enabled ? "postgres" : "kubernetes"
    }
    trainer = {
      auth = {
        oauthOidcTokenEndpoint = var.oauth_oidc_token_endpoint
        clientId               = var.operator_sa.client_id
        clientSecret           = var.operator_sa.client_secret
      }
    }
    packager = {
      auth = {
        oauthOidcTokenEndpoint = var.oauth_oidc_token_endpoint
        clientId               = var.operator_sa.client_id
        clientSecret           = var.operator_sa.client_secret
      }
    }
    packaging = {
      tolerations = length(local.packaging_node_pools) != 0 ? distinct(flatten([
        for nodepool in local.packaging_node_pools : [
          for taint in lookup(var.node_pools[nodepool], "taints", []) : {
            Key      = taint.key
            Operator = "Equal"
            Value    = taint.value
            Effect   = replace(taint.effect, "/(?i)no_?schedule/", "NoSchedule")
      }]])) : null

      nodePools = length(local.packaging_node_pools) != 0 ? [
        for k, v in var.node_pools :
        merge(
          { nodeSelector = { for key, value in v.labels : key => value } },
          { tags = compact(distinct(concat(
            try(v["tags"], []),
            [k, try(v["machine_type"], ""), try(v["preemptible"], "") == true ? "preemptible" : ""]
          ))) }
        )
        if contains(local.packaging_node_pools, k)
      ] : null

      namespace          = var.odahuflow_packaging_namespace
      outputConnectionID = "models-output"

      packagingIntegrationRepositoryType = var.pgsql_odahu.enabled ? "postgres" : "kubernetes"
    }
    migrate = {
      enabled = var.pgsql_odahu.enabled
    }
    serviceCatalog = {
      auth = {
        oauthOidcTokenEndpoint = var.oauth_oidc_token_endpoint
        clientId               = var.service_catalog_sa.client_id
        clientSecret           = var.service_catalog_sa.client_secret
      }
      edgeHost = var.cluster_domain
    }
    batch = {
      namespace = var.odahuflow_batch_namespace
      tolerations = length(local.deployment_node_pools) != 0 ? distinct(flatten([
        for nodepool in local.deployment_node_pools : [
          for taint in lookup(var.node_pools[nodepool], "taints", []) : {
            Key      = taint.key
            Operator = "Equal"
            Value    = taint.value
            Effect   = replace(taint.effect, "/(?i)no_?schedule/", "NoSchedule")
      }]])) : null

      nodePools = length(local.deployment_node_pools) != 0 ? [
        for k, v in var.node_pools :
        merge(
          { nodeSelector = { for key, value in v.labels : key => value } },
          { tags = compact(distinct(concat(
            try(v["tags"], []),
          [k, try(v["machine_type"], ""), try(v["preemptible"], "") == true ? "preemptible" : ""]))) }
        )
        if contains(local.deployment_node_pools, k)
      ] : null
    }
  }
  tools_config = {
    auth = {
      oauthOidcTokenEndpoint = var.oauth_oidc_token_endpoint
      clientId               = var.operator_sa.client_id
      clientSecret           = var.operator_sa.client_secret
    }
  }
  api_vault_volume = {
    name       = "vault-tls"
    mount_path = "/vault/tls"
  }
  api_config = {
    replicas = 2
    env = var.vault_enabled ? {
      VAULT_CACERT = join("/", [local.api_vault_volume.mount_path, "ca.crt"])
    } : {}
    volumeMounts = var.vault_enabled ? [
      {
        name      = local.api_vault_volume.name,
        mountPath = local.api_vault_volume.mount_path,
      }
    ] : []
    volumes = var.vault_enabled ? [
      {
        name = local.api_vault_volume.name,
        secret = {
          secretName = local.vault_tls_secret_name
        }
      }
    ] : []
  }

  odahu_docker_creds_present = length(var.docker_username) != 0 && length(var.docker_password) != 0
  odahu_docker_creds = {
    id = "odahuflow-docker-repository"
    spec = {
      type        = "docker"
      username    = var.docker_username
      password    = base64encode(var.docker_password)
      uri         = var.docker_repo
      description = "Docker repository for ODAHU services"
    }
  }
  odahu_docker_creds_connection = [{
    for key, value in local.odahu_docker_creds : key => value if local.odahu_docker_creds_present
  }]
  packagers = {
    triton = {
      targets = {
        docker_push = {
          default = local.default_model_docker_connection_id
        }
      }
    }
    rest = {
      targets = {
        docker_pull = {
          default = lookup(local.odahu_docker_creds_connection[0], "id", "")
        }
        docker_push = {
          default = local.default_model_docker_connection_id
        }
      }
    }
    cli = {
      targets = {
        docker_pull = {
          default = lookup(local.odahu_docker_creds_connection[0], "id", "")
        }
        docker_push = {
          default = local.default_model_docker_connection_id
        }
      }
    }
  }
  opa = {
    namespace = "odahu-flow-opa"
  }
}

########################################################
# ODAHU flow namespaces
########################################################

data "kubernetes_secret" "pg_odahu" {
  count = local.pg_odahu_credentials_plain == 0 ? 1 : 0
  metadata {
    name      = var.pgsql_odahu.secret_name
    namespace = var.pgsql_odahu.secret_namespace
  }
}

data "kubernetes_secret" "pg_mlflow" {
  count = local.pg_mlflow_credentials_plain == 0 ? 1 : 0
  metadata {
    name      = var.pgsql_mlflow.secret_name
    namespace = var.pgsql_mlflow.secret_namespace
  }
}

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

resource "kubernetes_namespace" "odahuflow_batch" {
  metadata {
    annotations = {
      name = var.odahuflow_batch_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.odahuflow_batch_namespace
  }
}

resource "kubernetes_namespace" "opa" {
  metadata {
    annotations = {
      name = local.opa.namespace
    }
    name = local.opa.namespace
  }
}


########################################################
# ODAHU flow secrets
########################################################

module "docker_credentials" {
  source             = "../../k8s/docker_auth"
  docker_repo        = var.docker_repo
  docker_username    = var.docker_username
  docker_password    = var.docker_password
  docker_secret_name = var.docker_secret_name
  namespaces = [
    kubernetes_namespace.odahuflow.metadata[0].annotations.name,
    kubernetes_namespace.odahuflow_training.metadata[0].annotations.name,
    kubernetes_namespace.odahuflow_packaging.metadata[0].annotations.name,
    kubernetes_namespace.odahuflow_deployment.metadata[0].annotations.name,
    kubernetes_namespace.odahuflow_batch.metadata[0].annotations.name,
  ]
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
    name      = var.vault_tls_secret_name
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
# Install ODAHU flow chart
########################################################

resource "helm_release" "odahuflow" {
  name       = "odahu-flow"
  chart      = "odahu-flow-core"
  version    = var.odahuflow_version
  namespace  = var.odahuflow_namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/odahuflow.yaml", {
      cluster_domain          = var.cluster_domain
      ingress_tls_enabled     = local.ingress_tls_enabled
      ingress_tls_secret_name = local.ingress_tls_secret_name
      knative_namespace       = var.knative_namespace

      docker_repo       = var.docker_repo
      docker_secret     = var.docker_secret_name
      odahuflow_version = var.odahuflow_version

      connections = yamlencode({
        connections = concat(
          var.odahuflow_connections,
          [for elem in local.odahu_docker_creds_connection : elem if length(elem) > 0]
        )
      })
      api_configuration     = yamlencode({ api = local.api_config })
      config                = yamlencode({ config = local.odahuflow_config })
      toolsConfig           = yamlencode({ toolsConfig = local.tools_config })
      resource_uploader_sa  = var.resource_uploader_sa
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
      oauth_mesh_enabled    = var.oauth_mesh_enabled
    }),
  ]

  depends_on = [
    kubernetes_namespace.odahuflow,
    kubernetes_namespace.odahuflow_training,
    kubernetes_namespace.odahuflow_deployment,
    kubernetes_namespace.odahuflow_batch,
    kubernetes_namespace.odahuflow_packaging,
    kubernetes_secret.odahuflow_vault_tls,
    helm_release.opa
  ]
}

########################################################
# Install ODAHU flow MLflow chart
########################################################

resource "helm_release" "mlflow" {
  name       = "odahu-flow-mlflow"
  chart      = "odahu-flow-mlflow"
  version    = var.mlflow_toolchain_version
  namespace  = var.odahuflow_namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout

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
      mlflow_backend_store  = local.mlflow_db_connection_string
      mlflow_artifact_root  = local.mlflow_artifact_root
    })
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}

########################################################
# Install ODAHU flow packagers
########################################################

resource "helm_release" "rest_packagers" {
  name       = "odahu-flow-packagers"
  chart      = "odahu-flow-packagers"
  version    = var.packager_version
  namespace  = var.odahuflow_namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/packagers.yaml", {
      docker_repo           = var.docker_repo
      packager_version      = var.packager_version
      odahuflow_version     = var.odahuflow_version
      resource_uploader_sa  = var.resource_uploader_sa
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
      oauth_mesh_enabled    = var.oauth_mesh_enabled
      packagers             = yamlencode({ packagers = local.packagers })
    })
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}

########################################################
# Install ODAHU flow UI
########################################################

resource "helm_release" "odahu_ui" {
  name       = "odahu-ui"
  chart      = "odahu-ui"
  version    = var.odahu_ui_version
  namespace  = var.odahuflow_namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/ui.yaml", {
      docker_repo      = var.docker_repo
      odahu_ui_version = var.odahu_ui_version

      cluster_domain          = var.cluster_domain
      ingress_tls_secret_name = local.ingress_tls_secret_name
      ingress_tls_enabled     = local.ingress_tls_enabled
    })
  ]

  depends_on = [
    helm_release.odahuflow
  ]
}


########################################################
# Install OpenPolicyAgent
########################################################

resource "helm_release" "opa" {
  name       = "odahu-flow-opa"
  chart      = "odahu-flow-opa"
  version    = var.opa_chart_version
  namespace  = local.opa.namespace
  repository = var.helm_repo
  timeout    = var.helm_timeout
  depends_on = [
    kubernetes_namespace.opa,
  ]
  values = [
    templatefile("${path.module}/templates/opa.yaml", {
      authz_dry_run = var.opa.dry_run
      authn_enabled = var.opa.authn.enabled
      ca            = var.opa.webhook_certs.ca
      key           = var.opa.webhook_certs.key
      cert          = var.opa.webhook_certs.cert

      oauth_oidc_jwks_url   = var.opa.authn.jwks_remote.jwks_url
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
      oauth_oidc_host       = var.opa.authn.jwks_remote.host
      oauth_oidc_port       = var.opa.authn.jwks_remote.port
      oauth_local_jwks      = base64decode(var.opa.authn.jwks_local)
    })
  ]
}
