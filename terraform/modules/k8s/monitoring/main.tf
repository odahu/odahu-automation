locals {
  ingress_tls_secret_name = "odahu-flow-tls"

  monitoring_values = {
    monitoring_namespace    = var.namespace
    odahu_infra_version     = var.odahu_infra_version
    cluster_domain          = var.cluster_domain
    grafana_admin           = var.grafana_admin
    grafana_pass            = var.grafana_pass
    grafana_storage_class   = var.grafana_storage_class
    ingress_tls_secret_name = local.ingress_tls_secret_name
  }
}

########################################################
# Prometheus monitoring
########################################################
resource "helm_release" "monitoring" {
  name       = "monitoring"
  chart      = "odahu-flow-monitoring"
  version    = var.odahu_infra_version
  namespace  = var.namespace
  repository = "odahuflow"
  timeout    = "600"

  values = [
    templatefile("${path.module}/templates/monitoring.yaml", local.monitoring_values)
  ]
}
