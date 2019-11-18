output "model_docker_user" {
  value = aws_iam_access_key.collector.id
}

output "model_docker_password" {
  value = aws_iam_access_key.collector.secret
}

output "model_docker_repo" {
  value = aws_ecr_repository.this.repository_url
}

output "model_docker_web_ui_link" {
  value = "https://${var.region}.console.aws.amazon.com/ecr/repositories/${aws_ecr_repository.this.name}/?region=${var.region}"
}

output "dockercfg" {
  value = {
    "${aws_ecr_repository.this.repository_url}" = {
      email    = ""
      username = "username"
      password = "password"
    }
  }
}

output "data_bucket" {
  value = aws_s3_bucket.this.id
}

output "data_bucket_region" {
  value = aws_s3_bucket.this.region
}

output "odahuflow_collector_iam_role" {
  value = aws_iam_role.collector.name
}

output "model_output_bucket" {
  value = "s3://${aws_s3_bucket.this.id}/output"
}

output "model_output_region" {
  value = var.region
}

output "model_output_secret" {
  value = aws_iam_access_key.collector.id
}

output "model_output_secret_key" {
  value = aws_iam_access_key.collector.secret
}

output "model_output_web_ui_link" {
  value = ""
}

output "bucket_registry_name" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.cluster_name}"
}

output "feedback_storage_link" {
  value = "https://s3.console.aws.amazon.com/s3/buckets/${var.data_bucket}/?region=${var.region}"
}
