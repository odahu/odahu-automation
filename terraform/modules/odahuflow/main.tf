########################################################
# Odahuflow secrets
########################################################

resource "kubernetes_secret" "tls_odahuflow" {
  metadata {
    name      = "${var.cluster_name}-tls"
    namespace = var.odahuflow_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.odahuflow]
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
      project = "odahuflow"
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
      project = "odahuflow"
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
      project = "odahuflow"
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
      project         = "odahuflow"
      istio-injection = "enabled"
    }
    name = var.odahuflow_deployment_namespace
  }
}

locals {
  vault_tls_secret_name = "vault-tls"
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

data "template_file" "odahuflow_values" {
  template = file("${path.module}/templates/odahuflow.yaml")
  vars = {
    odahuflow_namespace            = var.odahuflow_namespace
    odahuflow_training_namespace   = var.odahuflow_training_namespace
    odahuflow_packaging_namespace  = var.odahuflow_packaging_namespace
    odahuflow_deployment_namespace = var.odahuflow_deployment_namespace

    root_domain  = var.root_domain
    cluster_name = var.cluster_name
    cloud_type   = var.cloud_type

    docker_repo       = var.docker_repo
    odahuflow_version = var.odahuflow_version

    data_bucket                  = var.data_bucket
    data_bucket_region           = var.data_bucket_region
    odahuflow_collector_sa       = var.odahuflow_collector_sa
    odahuflow_collector_iam_role = var.odahuflow_collector_iam_role

    azure_storage_account   = var.azure_storage_account
    azure_storage_sas_token = "?${replace(var.model_output_secret, "/.+?\\?/", "")}"

    model_authorization_enabled = var.model_authorization_enabled
    model_oidc_jwks_url         = var.model_oidc_jwks_url
    model_oidc_issuer           = var.model_oidc_issuer

    git_examples_uri         = var.git_examples_uri
    git_examples_reference   = var.git_examples_reference
    git_examples_key         = var.git_examples_key
    git_examples_web_ui_link = var.git_examples_web_ui_link
    git_examples_description = var.git_examples_description

    model_resources_cpu = var.model_resources_cpu
    model_resources_mem = var.model_resources_mem

    model_output_bucket      = var.model_output_bucket
    model_output_region      = var.model_output_region
    model_output_secret      = var.model_output_secret
    model_output_secret_key  = var.model_output_secret_key
    model_output_description = "Storage for trained artifacts"
    model_output_web_ui_link = var.model_output_web_ui_link

    model_docker_user        = var.model_docker_user
    model_docker_password    = var.model_docker_password
    model_docker_repo        = var.model_docker_repo
    model_docker_description = "Docker repository for model packaging"
    model_docker_web_ui_link = var.model_docker_web_ui_link

    feedback_storage_link = var.feedback_storage_link

    odahuflow_connection_decrypt_token = var.odahuflow_connection_decrypt_token
  }
}

resource "helm_release" "odahuflow" {
  name       = "odahuflow"
  chart      = "odahuflow"
  version    = var.odahuflow_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    data.template_file.odahuflow_values.rendered,
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
# Install Odahuflow-mlflow charts
########################################################

data "template_file" "mlflow_values" {
  template = file("${path.module}/templates/mlflow.yaml")
  vars = {
    root_domain              = var.root_domain
    cluster_name             = var.cluster_name
    docker_repo              = var.docker_repo
    mlflow_toolchain_version = var.mlflow_toolchain_version
  }
}

resource "helm_release" "mlflow" {
  name       = "odahuflow-mlflow"
  chart      = "odahuflow-mlflow"
  version    = var.mlflow_toolchain_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    data.template_file.mlflow_values.rendered,
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
  name       = "odahuflow-rest-packager"
  chart      = "odahuflow-rest-packager"
  version    = var.packager_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    templatefile("${path.module}/templates/packagers.yaml", {
      docker_repo      = var.docker_repo
      packager_version = var.packager_version
    }),
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}

########################################################
# Install Odahuflow-mlflow charts
########################################################

resource "helm_release" "jupyterlab" {
  name       = "odahuflow-jupyterlab"
  chart      = "odahuflow-jupyterlab"
  version    = var.jupyterlab_version
  namespace  = var.odahuflow_namespace
  repository = data.helm_repository.odahuflow.metadata[0].name

  values = [
    templatefile("${path.module}/templates/jupyterlab.yaml", {
      root_domain        = var.root_domain
      cluster_name       = var.cluster_name
      docker_repo        = var.docker_repo
      jupyterlab_version = var.jupyterlab_version
    }),
  ]

  depends_on = [
    helm_release.odahuflow,
    kubernetes_namespace.odahuflow
  ]
}
