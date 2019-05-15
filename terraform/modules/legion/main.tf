provider "kubernetes" {
  config_context_auth_info  = "${var.config_context_auth_info}"
  config_context_cluster    = "${var.config_context_cluster}"
}

provider "helm" {
  install_tiller  = true
  namespace       = "kube-system"
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"
}

provider "google" {
  version     = "~> 2.2"
  # credentials = "${var.gcp_credentials}"
  region      = "${var.region}"
  zone        = "${var.zone}"
  project     = "${var.project_id}"
}

provider "aws" {
  region                    = "${var.region_aws}"
  shared_credentials_file   = "${var.aws_credentials_file}"
  profile                   = "${var.aws_profile}"
}


########################################################
# Install Legion dependencies
########################################################
resource "kubernetes_namespace" "legion" {
  metadata {
    annotations {
      name = "${var.legion_namespace}"
    }
    labels {
      project         = "legion"
      k8s-component   = "legion-app"
    }
    name = "${var.legion_namespace}"
  }
}

resource "google_storage_bucket" "legion_store" {
  name            = "${var.legion_data_bucket}"
  location        = "${var.region}"
  storage_class   = "REGIONAL"
  labels  {
    project = "legion"
    env     = "${var.cluster_name}"
  }
}

data "aws_s3_bucket_object" "tls-secret-key" {
  bucket = "${var.secrets_storage}"
  key    = "${var.cluster_name}/tls/${var.cluster_name}.key"
}

data "aws_s3_bucket_object" "tls-secret-crt" {
  bucket   = "${var.secrets_storage}"
  key      = "${var.cluster_name}/tls/${var.cluster_name}.fullchain.crt"
}

resource "kubernetes_secret" "tls_legion" {
  metadata {
    name        = "${var.cluster_name}-tls"
    namespace   = "${var.legion_namespace}"
  }
  data {
    "tls.key"   = "${data.aws_s3_bucket_object.tls-secret-key.body}}"
    "tls.crt"   = "${data.aws_s3_bucket_object.tls-secret-crt.body}}"
  }
  type          = "kubernetes.io/tls"
}

########################################################
# Install Legion charts
########################################################
data "helm_repository" "legion" {
    name = "legion_github"
    url  = "${var.legion_helm_repo}"
}

data "template_file" "legion_values" {
  template = "${file("${path.module}/templates/legion.yaml")}"
  vars = {
    legion_namespace        = "${var.legion_namespace}"
    root_domain             = "${var.root_domain}"
    cluster_name            = "${var.cluster_name}"
    docker_repo             = "${var.docker_repo}"
    legion_version          = "${var.legion_version}"
    enclave_jwt_secret      = "${var.enclave_jwt_secret}"
    api_jwt_ttl_minutes     = "${var.api_jwt_ttl_minutes}"
    max_token_ttl_minutes   = "${var.max_token_ttl_minutes}"
    api_jwt_exp_datetime    = "${var.api_jwt_exp_datetime}"
    model_docker_protocol   = "${var.model_docker_protocol}"
    model_docker_url        = "${var.model_docker_url}"
    docker_user             = "${var.docker_user}"
    docker_password         = "${var.docker_password}"
    legion_data_bucket      = "${var.legion_data_bucket}"
    collector_region        = "${var.collector_region}"
    model_examples_git_url  = "${var.model_examples_git_url}"
    model_reference         = "${var.model_reference}"
    jenkins_git_key         = "${var.jenkins_git_key}"
    model_resources_cpu     = "${var.model_resources_cpu}"
    model_resources_mem     = "${var.model_resources_mem}"
  }
}

# TODO: debug
resource "local_file" "foo" {
    content     = "${data.template_file.legion_values.rendered}"
    filename = "/tmp/${var.cluster_name}-legion-values.yaml"
}

resource "helm_release" "legion_crds" {
    name        = "legion-crds"
    chart       = "legion-crds"
    version     = "${var.legion_version}"
    namespace   = "${var.legion_namespace}"
    repository  = "${data.helm_repository.legion.metadata.0.name}"

    values = [
      "${data.template_file.legion_values.rendered}"
    ]
}

resource "helm_release" "legion" {
    name        = "legion"
    chart       = "legion"
    version     = "${var.legion_version}"
    namespace   = "${var.legion_namespace}"
    repository  = "${data.helm_repository.legion.metadata.0.name}"

    values = [
      "${data.template_file.legion_values.rendered}"
    ]
    depends_on    = ["helm_release.legion"]
}
