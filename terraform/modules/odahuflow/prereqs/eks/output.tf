output "extra_external_urls" {
  value = [
    {
      name     = "Feedback storage"
      url      = "https://s3.console.aws.amazon.com/s3/buckets/${var.data_bucket}/?region=${var.region}"
      imageUrl = "/img/logo/aws-s3.png"
    }
  ]
}

output "odahu_bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "odahuflow_connections" {
  value = [
    {
      id = "docker-ci"
      spec = {
        type        = "ecr"
        keyID       = aws_iam_access_key.collector.id
        keySecret   = aws_iam_access_key.collector.secret
        uri         = aws_ecr_repository.this.repository_url
        description = "Default ECR docker repository for model packaging"
        webUILink   = "https://${var.region}.console.aws.amazon.com/ecr/repositories/${aws_ecr_repository.this.name}/?region=${var.region}"
      }
    },
    {
      id = "models-output"
      spec = {
        type        = "s3"
        keyID       = aws_iam_access_key.collector.id
        keySecret   = aws_iam_access_key.collector.secret
        uri         = "s3://${aws_s3_bucket.this.id}/output"
        region      = aws_s3_bucket.this.region
        description = ""
        webUILink   = "Storage for trained artifacts"
      }
    }
  ]
}

output "fluent_helm_values" {
  value = templatefile("${path.module}/templates/fluentd.yaml", {
    data_bucket        = aws_s3_bucket.this.id
    data_bucket_region = aws_s3_bucket.this.region
    collector_iam_role = aws_iam_role.collector.name
  })
}

output "fluent_daemonset_helm_values" {
  value = templatefile("${path.module}/templates/fluentd_daemonset.yaml", {
    data_bucket        = aws_s3_bucket.this.id
    data_bucket_region = aws_s3_bucket.this.region
    collector_iam_role = aws_iam_role.collector.name
  })
}

output "logstash_input_config" {
  value = templatefile("${path.module}/templates/logstash.yaml", {
    bucket = aws_s3_bucket.this.id
    region = aws_s3_bucket.this.region
  })
}

output "logstash_annotations" {
  value = {
    podAnnotations = {
      "sidecar.istio.io/inject" = "false"
      "iam.amazonaws.com/role"  = aws_iam_role.collector.name
    }
  }
}

