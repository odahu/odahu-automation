########################################################
# Legion secrets
########################################################

resource "kubernetes_secret" "tls_legion" {
  metadata {
    name      = "${var.cluster_name}-tls"
    namespace = var.legion_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.legion]
}

########################################################
# Legion namespaces
########################################################

resource "kubernetes_namespace" "legion" {
  metadata {
    annotations = {
      name = var.legion_namespace
    }
    labels = {
      project = "legion"
    }
    name = var.legion_namespace
  }
}

resource "kubernetes_namespace" "legion_training" {
  metadata {
    annotations = {
      name = var.legion_training_namespace
    }
    labels = {
      project = "legion"
    }
    name = var.legion_training_namespace
  }
}

resource "kubernetes_namespace" "legion_packaging" {
  metadata {
    annotations = {
      name = var.legion_packaging_namespace
    }
    labels = {
      project = "legion"
    }
    name = var.legion_packaging_namespace
  }
}

resource "kubernetes_namespace" "legion_deployment" {
  metadata {
    annotations = {
      name = var.legion_deployment_namespace
    }
    labels = {
      project         = "legion"
      istio-injection = "enabled"
    }
    name = var.legion_deployment_namespace
  }
}

########################################################
# Install Legion chart
########################################################

data "helm_repository" "legion" {
  name = "legion"
  url  = var.legion_helm_repo
}

data "template_file" "legion_values" {
  template = file("${path.module}/templates/legion.yaml")
  vars = {
    legion_namespace            = var.legion_namespace
    legion_training_namespace   = var.legion_training_namespace
    legion_packaging_namespace  = var.legion_packaging_namespace
    legion_deployment_namespace = var.legion_deployment_namespace

    root_domain  = var.root_domain
    cluster_name = var.cluster_name
    cloud_type   = var.cloud_type

    docker_repo    = var.docker_repo
    legion_version = var.legion_version

    legion_data_bucket        = var.legion_data_bucket
    legion_data_bucket_region = var.legion_data_bucket_region
    legion_collector_sa       = var.legion_collector_sa
    legion_collector_iam_role = var.legion_collector_iam_role

    azure_storage_account    = var.azure_storage_account
    azure_storage_access_key = var.azure_storage_access_key

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
    model_output_description = "Storage for trained artifacts"
    model_output_web_ui_link = var.model_output_web_ui_link

    model_docker_user        = var.model_docker_user
    model_docker_password    = var.model_docker_password
    model_docker_repo        = var.model_docker_repo
    model_docker_description = "Docker repository for model packaging"
    model_docker_web_ui_link = var.model_docker_web_ui_link

    feedback_storage_link = var.feedback_storage_link
  }
}

resource "helm_release" "legion" {
  name       = "legion"
  chart      = "legion"
  version    = var.legion_version
  namespace  = var.legion_namespace
  repository = data.helm_repository.legion.metadata[0].name

  values = [
    data.template_file.legion_values.rendered,
  ]

  depends_on = [
    kubernetes_namespace.legion,
    kubernetes_namespace.legion_training,
    kubernetes_namespace.legion_deployment,
    kubernetes_namespace.legion_packaging,
    data.helm_repository.legion,
  ]
}

########################################################
# Install Legion-mlflow charts
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
  name       = "legion-mlflow"
  chart      = "legion-mlflow"
  version    = var.mlflow_toolchain_version
  namespace  = var.legion_namespace
  repository = data.helm_repository.legion.metadata[0].name

  values = [
    data.template_file.mlflow_values.rendered,
  ]

  depends_on = [
    helm_release.legion,
    kubernetes_namespace.legion
  ]
}

########################################################
# Create a docker pull secret for knative
# TODO: move this logic to legion deployment operator later
########################################################

resource "kubernetes_secret" "regsecret" {
  metadata {
    name      = "regsecret"
    namespace = var.legion_deployment_namespace
  }

  data = {
    ".dockercfg" = jsonencode(var.dockercfg)
  }

  type = "kubernetes.io/dockercfg"

  depends_on = [kubernetes_namespace.legion_deployment]
}

resource "kubernetes_service_account" "regsecret" {
  metadata {
    name      = "regsecret"
    namespace = var.legion_deployment_namespace
  }
  image_pull_secret {
    name = "regsecret"
  }

  depends_on = [kubernetes_namespace.legion_deployment]
}
