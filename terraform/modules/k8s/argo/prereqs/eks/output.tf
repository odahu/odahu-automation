output "argo_sa_annotations" {
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.argo.arn
  }
}

output "argo_artifact_repository_config" {
  value = {
    s3 = {
      useSDKCreds = true,
      region      = data.aws_s3_bucket.argo.region,
      endpoint    = "s3.amazonaws.com",
      bucket      = data.aws_s3_bucket.argo.bucket,
      keyFormat   = "argo/{{workflow.namespace}}/{{workflow.name}}/"
    }
  }
}
