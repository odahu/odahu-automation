data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.azure_resource_group
}

locals {
  config_context_auth_info = var.config_context_auth_info == "" ? data.azurerm_kubernetes_cluster.aks.kube_config.0.username : var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster == "" ? var.cluster_name : var.config_context_cluster

  common_tags = merge(
    { cluster = var.cluster_name },
    var.aks_common_tags
  )

  dag_bucket = var.airflow["dag_bucket"] == "" ? module.odahuflow_prereqs.odahu_bucket_name : var.airflow["dag_bucket"]

  dag_bucket_path = var.airflow["dag_bucket_path"] == "" ? "/dags" : var.airflow["dag_bucket_path"]
}
