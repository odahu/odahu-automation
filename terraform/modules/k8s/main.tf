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
# K8S Cluster Setup
########################################################
data "aws_s3_bucket_object" "tls-secret-key" {
  bucket = "${var.secrets_storage}"
  key    = "${var.cluster_name}/tls/${var.cluster_name}.key"
}

data "aws_s3_bucket_object" "tls-secret-crt" {
  bucket   = "${var.secrets_storage}"
  key      = "${var.cluster_name}/tls/${var.cluster_name}.fullchain.crt"
}

# Install TLS cert as a secret
resource "kubernetes_secret" "tls_default" {
  count   = "${length(var.tls_namespaces)}"
  metadata {
    name        = "${var.cluster_name}-tls"
    namespace   = "${element(var.tls_namespaces, count.index)}"
  }
  data {
    "tls.key"   = "${data.aws_s3_bucket_object.tls-secret-key.body}}"
    "tls.crt"   = "${data.aws_s3_bucket_object.tls-secret-crt.body}}"
  }
  type          = "kubernetes.io/tls"
}

########################################################
# Nginx Ingress
########################################################
resource "helm_release" "nginx-ingress" {
    name      = "nginx-ingress"
    chart     = "stable/nginx-ingress"
    namespace = "kube-system"
    version   = "0.20.1"
    # TODO: restrict access to Ingress LBs
    # set {
    #     name  = "controller.service.loadBalancerSourceRanges"
    #     value = "${var.allowed_ips}"
    # }
    set {
      name    = "defaultBackend.service.type"
      value   = "LoadBalancer"
    }
}

# Nginx ingress public DNS
# TODO: add public DNS wildcard record

########################################################
# Kubernetes Dashboard
########################################################
resource "helm_release" "kubernetes-dashboard" {
    name      = "kubernetes-dashboard"
    chart     = "stable/kubernetes-dashboard"
    namespace = "kube-system"
    version   = "0.6.8"
    values = [
      "${file("${path.module}/templates/dashboard-ingress.yaml")}"
    ]
}

resource "kubernetes_secret" "tls_dashboard" {
  metadata {
    name        = "kubernetes-dashboard-certs"
    namespace   = "kube-system"
  }
  data {
    "tls.key"   = "${data.aws_s3_bucket_object.tls-secret-key.body}}"
    "tls.crt"   = "${data.aws_s3_bucket_object.tls-secret-crt.body}}"
  }
  type          = "kubernetes.io/tls"
}

########################################################
# Dex setup
########################################################
data "template_file" "dex_values" {
  template = "${file("${path.module}/templates/dex.yaml")}"
  vars = {
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
    dex_replicas              = "${var.dex_replicas}"
    dex_github_clientid       = "${var.dex_github_clientid}"
    dex_github_clientSecret   = "${var.dex_github_clientSecret}"
    github_org_name           = "${var.github_org_name}"
    dex_client_secret         = "${var.dex_client_secret}"
    dex_static_user_email     = "${var.dex_static_user_email}"
    dex_static_user_pass      = "${var.dex_static_user_pass}"
    dex_static_user_hash      = "${var.dex_static_user_hash}"
    dex_static_user_name      = "${var.dex_static_user_name}"
    dex_static_user_id        = "${var.dex_static_user_id}"
  }
}

resource "helm_release" "dex" {
    name        = "dex"
    chart       = "dex"
    version     = "${var.legion_infra_version}"
    namespace   = "kube-system"
    repository  = "${data.helm_repository.legion.metadata.0.name}"

    values = [
      "${data.template_file.dex_values.rendered}"
    ]
}
########################################################
# Prometheus monitoring
########################################################
resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations {
      name = "${var.monitoring_namespace}"
    }
    labels {
      project         = "legion"
      k8s-component   = "monitoring"
    }
    name = "${var.monitoring_namespace}"
  }
}

# resource "kubernetes_storage_class" "pd_standard" {
#   metadata {
#     name = "${var.grafana_storage_class}"
#   }
#   storage_provisioner = "kubernetes.io/gce-pd"
#   reclaim_policy = "Retain"
#   parameters {
#     type = "${var.grafana_storage_class}"
#     zone = "${var.zone}"
#   }
# }

resource "kubernetes_secret" "tls_monitoring" {
  metadata {
    name        = "${var.cluster_name}-tls"
    namespace   = "${var.monitoring_namespace}"
  }
  data {
    "tls.key"   = "${data.aws_s3_bucket_object.tls-secret-key.body}"
    "tls.crt"   = "${data.aws_s3_bucket_object.tls-secret-crt.body}}"
  }
  type          = "kubernetes.io/tls"
  depends_on    = ["kubernetes_namespace.monitoring"]
}

# TODO: replace raw exec after terraform crd resource release
resource "null_resource" "prometheus_crd_alertmanager" {
  count   = "${length(var.prometheus_crds)}"
  provisioner "local-exec" {
    command = "kubectl --context ${var.cluster_context} apply -f ${var.monitoring_prometheus_operator_crd_url}/${element(var.prometheus_crds, count.index)}.crd.yaml"
  }
}

data "helm_repository" "legion" {
    name = "legion_github"
    url  = "${var.legion_helm_repo}"
}

data "template_file" "monitoring_values" {
  template = "${file("${path.module}/templates/monitoring.yaml")}"
  vars = {
    monitoring_namespace      = "${var.monitoring_namespace}"
    legion_infra_version      = "${var.legion_infra_version}"
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
    docker_repo               = "${var.docker_repo}"
    alert_slack_url           = "${var.alert_slack_url}"
    grafana_admin             = "${var.grafana_admin}"
    grafana_pass              = "${var.grafana_pass}"
    grafana_storage_class     = "${var.grafana_storage_class}"
  }
}

resource "helm_release" "monitoring" {
    name        = "monitoring"
    chart       = "monitoring"
    version     = "${var.legion_infra_version}"
    namespace   = "${var.monitoring_namespace}"
    repository  = "${data.helm_repository.legion.metadata.0.name}"

    values = [
      "${data.template_file.monitoring_values.rendered}"
    ]
}
