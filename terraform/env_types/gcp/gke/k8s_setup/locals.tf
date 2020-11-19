locals {
  dag_bucket = var.airflow["dag_bucket"] == "" ? module.odahuflow_prereqs.odahu_data_bucket_name : var.airflow["dag_bucket"]

  dag_bucket_path = var.airflow["dag_bucket_path"] == "" ? "/dags" : var.airflow["dag_bucket_path"]

  is_lb_an_ip  = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$", module.nginx_ingress_prereqs.helm_values["controller.service.loadBalancerIP"])) > 0

  databases = [
    "airflow",
    "mlflow",
    "jupyterhub",
    "vault",
    var.odahu_database,
    "grafana"
  ]
}
