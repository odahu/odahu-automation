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
    set {
      name    = "defaultBackend.service.type"
      value  = "LoadBalancer"
    }
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
    set {
        name  = "service.type"
        value = "LoadBalancer"
    }
}

########################################################
# Dex setup
########################################################



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

resource "kubernetes_secret" "tls_monitoring" {
  metadata {
    name        = "${var.cluster_name}-tls"
    namespace   = "${var.monitoring_namespace}"
  }
  data {
    "tls.key"   = "${data.google_storage_bucket_object.tls-secret-key.self_link}"
    "tls.crt"   = "${data.google_storage_bucket_object.tls-secret-crt.self_link}}"
  }
  type          = "kubernetes.io/tls"
  depends_on    = ["kubernetes_namespace.monitoring"]
}

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
    monitoring_namespace  = "${var.monitoring_namespace}"
    alert_slack_url       = "${var.alert_slack_url}"
    root_domain           = "${var.root_domain}"
    cluster_name          = "${var.cluster_name}"
    grafana_admin         = "${var.grafana_admin}"
    grafana_pass          = "${var.grafana_pass}"
    docker_repo           = "${var.docker_repo}"
    legion_infra_version  = "${var.legion_infra_version}"

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
