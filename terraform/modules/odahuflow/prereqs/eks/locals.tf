locals {
  log_bucket         = var.log_bucket == "" ? aws_s3_bucket.data.id : aws_s3_bucket.logs[0].id
  log_bucket_region  = var.log_bucket == "" ? aws_s3_bucket.data.region : aws_s3_bucket.logs[0].region
  mlflow_iam_name    = substr("${var.cluster_name}-mlflow", 0, 30)
  mlflow_bucket_name = var.mlflow_artifact_bucket == "" ? "${var.cluster_name}-mlflow" : var.mlflow_artifact_bucket

  fluentd = {
    "fluentd" = {
      "resources" = {
        "limits" = {
          "cpu": var.fluentd_resources.cpu_limits
          "memory": var.fluentd_resources.memory_limits
        }
        "requests" = {
          "cpu": var.fluentd_resources.cpu_requests
          "memory": var.fluentd_resources.memory_requests
        }
      }
    }
  }
}

