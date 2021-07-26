output "extra_external_urls" {
  value = [
    {
      name = "Feedback storage"
      url = format(
        "https://console.cloud.google.com/storage/browser/%s/model_log?project=%s",
        google_storage_bucket.data.name,
        var.project_id
      )
      imageUrl = "/img/logo/gcs.png"
    }
  ]
}

output "odahu_data_bucket_name" {
  value = google_storage_bucket.data.name
}

output "odahu_mlflow_bucket_name" {
  value = google_storage_bucket.mlflow.name
}

output "odahu_log_bucket_name" {
  value = google_storage_bucket.log.name
}

output "argo_artifact_bucket_name" {
  value = var.argo_artifact_bucket == "" ? "" : google_storage_bucket.argo_artifacts[0].name
}

output "odahu_collector_sa_key" {
  value = local.collector_sa_key_one_line
}

output "odahuflow_connections" {
  value = [
    {
      id = "docker-ci",
      spec = {
        type        = "docker"
        username    = local.model_docker_user
        password    = google_service_account_key.collector_sa_key.private_key
        uri         = "${data.google_container_registry_repository.odahuflow_registry.repository_url}/${var.cluster_name}"
        description = "Default GCR docker repository for model packaging"
        webUILink   = local.model_docker_web_ui_link
      }
    },
    {
      id = "models-output",
      spec = {
        type        = "gcs"
        keySecret   = google_service_account_key.collector_sa_key.private_key
        uri         = "${google_storage_bucket.data.url}/output"
        region      = var.project_id
        description = "Storage for trained artifacts"
        webUILink = format(
          "https://console.cloud.google.com/storage/browser/%s/output?project=%s",
          google_storage_bucket.data.name,
          var.project_id
        )
      }
    }
  ]
}

output "fluent_helm_values" {
  value = templatefile("${path.module}/templates/fluentd.yaml", {
    data_bucket     = google_storage_bucket.data.name,
    collector_sa    = google_service_account.collector_sa.email
    fluentd         = yamlencode(local.fluentd)
  })
}

output "fluent_daemonset_helm_values" {
  value = {
    config = templatefile("${path.module}/templates/fluentd_ds_cloud.tpl", {
      data_bucket = google_storage_bucket.log.name
    })

    annotations = {}
    sa_annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.collector_sa.email
    }
    envs = []

    secrets = []
  }
}

output "jupyter_notebook_sa_annotations" {
  value = {
    "iam.gke.io/gcp-service-account" = google_service_account.jupyter_notebook.email
  }
}

output "mlflow_sa_annotations" {
  value = {
    "iam.gke.io/gcp-service-account" = google_service_account.mlflow.email
  }
}

output "logstash_input_config" {
  value = templatefile("${path.module}/templates/logstash.yaml", {
    bucket = google_storage_bucket.log.name
  })
}

output "logstash_annotations" {
  value = {
    sa_annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.collector_sa.name
    }
  }
}

