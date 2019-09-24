provider "kubernetes" {
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
}

provider "helm" {
  install_tiller  = true
  namespace       = "kube-system"
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"
}

provider "google" {
  version = "~> 2.2"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

resource "kubernetes_secret" "tls_legion" {
  metadata {
    name      = "${var.cluster_name}-tls"
    namespace = var.legion_namespace
  }
  data = {
    "tls.key" = var.tls-secret-key
    "tls.crt" = var.tls-secret-crt
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
# GCS bucket
########################################################

resource "google_storage_bucket" "legion_store" {
  name          = var.legion_data_bucket
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true
  labels = {
    project = "legion"
    env     = var.cluster_name
  }
}

locals {
  gsa_collector_name   = "${var.cluster_name}-collector"
  bucket_registry_name = "artifacts.${var.project_id}.appspot.com"
}

resource "google_service_account" "collector_sa" {
  account_id   = local.gsa_collector_name
  display_name = local.gsa_collector_name
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "legion_store_legacy_write" {
  bucket = google_storage_bucket.legion_store.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.legacyBucketWriter"
}

resource "google_storage_bucket_iam_member" "legion_store" {
  bucket = google_storage_bucket.legion_store.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "legion_registry" {
  bucket = local.bucket_registry_name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.admin"
}

data "google_container_registry_repository" "legion_registry" {
}

########################################################
# Install Legion chart
########################################################

resource "google_service_account_key" "collector_sa_key" {
  service_account_id = google_service_account.collector_sa.name
}

data "helm_repository" "legion" {
  name = "legion"
  url  = var.legion_helm_repo
}

locals {
  // This hack is used to transform the json key to one line
  collector_sa_key_one_line = jsonencode(jsondecode(base64decode(google_service_account_key.collector_sa_key.private_key)))

  model_docker_user        = "_json_key"
  model_docker_password    = local.collector_sa_key_one_line
  model_docker_repo        = "${data.google_container_registry_repository.legion_registry.repository_url}/${var.cluster_name}"
  model_docker_description = "GCP Docker repository for model packaging"
  model_docker_web_ui_link = "https://${local.model_docker_repo}"

  model_output_bucket      = "${google_storage_bucket.legion_store.url}/output"
  model_output_region      = var.project_id
  model_output_secret      = local.collector_sa_key_one_line
  model_output_description = "Storage for trainined artifacts"
  model_output_web_ui_link = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.legion_store.name}/output?project=${var.project_id}"

  feedback_storage_link = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.legion_store.name}/model_log?project=${var.project_id}"
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

    docker_repo    = var.docker_repo
    legion_version = var.legion_version

    legion_data_bucket  = var.legion_data_bucket
    legion_collector_sa = google_service_account.collector_sa.email

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

    model_output_bucket      = local.model_output_bucket
    model_output_region      = local.model_output_region
    model_output_secret      = local.model_output_secret
    model_output_description = local.model_output_description
    model_output_web_ui_link = local.model_output_web_ui_link

    model_docker_user        = local.model_docker_user
    model_docker_password    = local.model_docker_password
    model_docker_repo        = local.model_docker_repo
    model_docker_description = local.model_docker_description
    model_docker_web_ui_link = local.model_docker_web_ui_link

    feedback_storage_link = local.feedback_storage_link
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

locals {
  dockercfg = {
    "https://gcr.io" = {
      email    = ""
      username = local.model_docker_user
      password = local.model_docker_password
    }
  }
}

resource "kubernetes_secret" "regsecret" {
  metadata {
    name      = "regsecret"
    namespace = var.legion_deployment_namespace
  }

  data = {
    ".dockercfg" = jsonencode(local.dockercfg)
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