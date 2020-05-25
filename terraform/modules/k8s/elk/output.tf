output "external_url" {
  value = var.elk_enabled ? [{
    name     = "Kibana",
    url      = "${local.url_schema}://${var.cluster_domain}/kibana",
    imageUrl = "/img/logo/kibana.png"
  }] : []
}
