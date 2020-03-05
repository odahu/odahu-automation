locals {
  ingress_tls_secret_name = "odahu-flow-tls"
}

########################################################
# Prometheus monitoring
########################################################
resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = var.monitoring_namespace
    }
    labels = {
      project       = "odahuflow"
      k8s-component = "monitoring"
    }
    name = var.monitoring_namespace
  }
  timeouts {
    delete = "15m"
  }
}

resource "kubernetes_secret" "tls_monitoring" {
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.monitoring_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type       = "kubernetes.io/tls"
  depends_on = [kubernetes_namespace.monitoring]
}

data "template_file" "monitoring_values" {
  template = file("${path.module}/templates/monitoring.yaml")
  vars = {
    monitoring_namespace    = var.monitoring_namespace
    odahu_infra_version     = var.odahu_infra_version
    cluster_domain          = var.cluster_domain
    grafana_admin           = var.grafana_admin
    grafana_pass            = var.grafana_pass
    grafana_storage_class   = var.grafana_storage_class
    ingress_tls_secret_name = local.ingress_tls_secret_name
  }
}

resource "helm_release" "monitoring" {
  name       = "monitoring"
  chart      = "odahu-flow-monitoring"
  version    = var.odahu_infra_version
  namespace  = var.monitoring_namespace
  repository = "odahuflow"
  timeout    = "600"

  values = [
    data.template_file.monitoring_values.rendered
  ]

  depends_on = [kubernetes_namespace.monitoring]
}
