locals {
  log_bucket        = var.log_bucket == "" ? aws_s3_bucket.data.id : aws_s3_bucket.logs[0].id
  log_bucket_region = var.log_bucket == "" ? aws_s3_bucket.data.region : aws_s3_bucket.logs[0].region

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

