output "external_url" {
  value = var.configuration.enabled ? [
    {
      name     = "Airflow",
      url      = "${local.url_schema}://${var.cluster_domain}/airflow",
      imageUrl = "/img/logo/airflow.png"
    }
  ] : []
}
