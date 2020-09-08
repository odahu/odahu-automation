locals {
  dag_bucket = var.airflow["dag_bucket"] == "" ? module.odahuflow_prereqs.odahu_bucket_name : var.airflow["dag_bucket"]

  dag_bucket_path = var.airflow["dag_bucket_path"] == "" ? "/dags" : var.airflow["dag_bucket_path"]

  databases = [
    "airflow",
    "mlflow",
    "jupyterhub",
    "vault",
    var.odahu_database
  ]
}
