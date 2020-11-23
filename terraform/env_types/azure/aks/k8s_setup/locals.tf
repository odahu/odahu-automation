data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.azure_resource_group
}

locals {
  config_context_auth_info = var.config_context_auth_info == "" ? data.azurerm_kubernetes_cluster.aks.kube_config.0.username : var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster == "" ? var.cluster_name : var.config_context_cluster

  is_lb_an_ip = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$", module.nginx_ingress_prereqs.load_balancer_ip)) > 0

  common_tags = merge({
    "cluster"    = var.cluster_name,
    "project"    = "odahu-flow",
    "created-on" = timestamp()
    },
    var.aks_common_tags
  )

  dag_bucket = var.airflow["dag_bucket"] == "" ? module.odahuflow_prereqs.odahu_data_bucket_name : var.airflow["dag_bucket"]

  dag_bucket_path = var.airflow["dag_bucket_path"] == "" ? "/dags" : var.airflow["dag_bucket_path"]

  databases = [
    "airflow",
    "mlflow",
    "jupyterhub",
    "vault",
    var.odahu_database,
    "grafana"
  ]
}
