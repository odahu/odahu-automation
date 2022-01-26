output "extra_external_urls" {
  value = [
    {
      name     = "Feedback storage"
      url      = "https://s3.console.aws.amazon.com/s3/buckets/${var.data_bucket}/?region=${var.region}"
      imageUrl = "/img/logo/aws-s3.png"
    }
  ]
}

output "odahu_data_bucket_name" {
  value = aws_s3_bucket.data.bucket
}

output "odahu_mlflow_bucket_name" {
  value = aws_s3_bucket.mlflow.bucket
}

output "odahu_log_bucket_name" {
  value = var.log_bucket == "" ? "" : aws_s3_bucket.logs[0].bucket
}

output "odahuflow_connections" {
  value = [
    {
      id = "docker-ci"
      spec = {
        type        = "ecr"
        keyID       = base64encode(aws_iam_access_key.collector.id)
        keySecret   = base64encode(aws_iam_access_key.collector.secret)
        uri         = aws_ecr_repository.this.repository_url
        description = "Default ECR docker repository for model packaging"
        webUILink   = "https://${var.region}.console.aws.amazon.com/ecr/repositories/${aws_ecr_repository.this.name}/?region=${var.region}"
        vital       = var.vital_enable
      }
    },
    {
      id = "models-output"
      spec = {
        type        = "s3"
        keyID       = base64encode(aws_iam_access_key.collector.id)
        keySecret   = base64encode(aws_iam_access_key.collector.secret)
        uri         = "s3://${aws_s3_bucket.data.id}/output"
        region      = aws_s3_bucket.data.region
        description = ""
        webUILink   = "Storage for trained artifacts"
        vital       = var.vital_enable
      }
    }
  ]
}

output "fluent_helm_values" {
  value = templatefile("${path.module}/templates/fluentd.yaml", {
    data_bucket        = aws_s3_bucket.data.id
    data_bucket_region = aws_s3_bucket.data.region
    collector_iam_role = aws_iam_role.collector.arn
    fluentd            = yamlencode(local.fluentd)
  })
}

output "fluent_daemonset_helm_values" {
  value = {
    config = templatefile("${path.module}/templates/fluentd_ds_cloud.tpl", {
      data_bucket        = local.log_bucket
      data_bucket_region = local.log_bucket_region
      iam_role_arn       = aws_iam_role.collector.arn
    })

    annotations = {}
    sa_annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.collector.arn
    }

    envs = []

    secrets = []
  }
}

output "logstash_input_config" {
  value = templatefile("${path.module}/templates/logstash.yaml", {
    bucket            = local.log_bucket
    region            = local.log_bucket_region
    access_key_id     = aws_iam_access_key.collector.id
    secret_access_key = aws_iam_access_key.collector.secret
  })
}

output "logstash_annotations" {
  value = {
    sa_annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.collector.arn
    }
  }
}

output "jupyter_notebook_sa_annotations" {
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.jupyter_notebook.arn
  }
}

output "training_sa_annotations" {
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.mlflow.arn
  }
}

output "mlflow_sa_annotations" {
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.mlflow.arn
  }
}
