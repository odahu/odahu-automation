output "argo_artifact_repository_config" {
  value = {
    s3 = {
      endpoint  = "s3.amazonaws.com",
      bucket    = "data.aws_s3_bucket.argo.bucket",
      keyFormat = "argo/{{workflow.namespace}}/{{workflow.name}}/"
      accessKeySecret = {
        name = "argo"
        key  = "argo"
      }
      secretKeySecret = {
        name = "argo"
        key  = "argo"
      }
    }
  }
}

output "external_url" {
  value = [
    {
      name     = "Minio console",
      url      = "${local.url_schema}://${var.cluster_domain}/minio/",
      imageUrl = "/img/logo/minio.png"
    }
  ]
}
