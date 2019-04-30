provider "kubernetes" {
  config_context_auth_info  = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_legion-dev"
  config_context_cluster    = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_legion-dev"
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

########################################################
# K8S Cluster Setup
########################################################
data "google_storage_bucket_object" "tls-secret-key" {
  bucket   = "${var.secrets_storage}"
  name     =  "${var.tls_name}.key"
}

data "google_storage_bucket_object" "tls-secret-crt" {
  bucket   = "${var.secrets_storage}"
  name     = "${var.tls_name}.fullchain.crt"
}

# Install TLS cert as a secret
resource "kubernetes_secret" "tls_default" {
  count   = "${length(var.tls_namespaces)}"
  metadata {
    name        = "${var.cluster_name}-tls"
    namespace   = "${element(var.tls_namespaces, count.index)}"
  }
  data {
    "tls.key"   = "${data.google_storage_bucket_object.tls-secret-key.self_link}}"
    "tls.crt"   = "${data.google_storage_bucket_object.tls-secret-crt.self_link}}"
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
    # set {
    #     name  = "controller.service.loadBalancerSourceRanges"
    #     value = "${var.allowed_ips}"
    # }

}

########################################################
# Kubernetes Dashboard
########################################################
resource "helm_release" "kubernetes-dashboard" {
    name      = "kubernetes-dashboard"
    chart     = "stable/kubernetes-dashboard"
    namespace = "kube-system"
    version   = "0.6.8"
    set {
        name  = "ingress.enabled"
        value = "true"
    }
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
      project = "legion"
    }

    name = "${var.monitoring_namespace}"
  }
}

resource "kubernetes_secret" "tls_monitoring" {
  count   = "${length(var.tls_namespaces)}"
  metadata {
    name        = "${var.cluster_name}-tls"
    namespace   = "${var.monitoring_namespace}"
  }
  data {
    "tls.key"   = "${data.google_storage_bucket_object.tls-secret-key.self_link}"
    "tls.crt"   = "${data.google_storage_bucket_object.tls-secret-crt.self_link}}"
  }
  type          = "kubernetes.io/tls"
}
