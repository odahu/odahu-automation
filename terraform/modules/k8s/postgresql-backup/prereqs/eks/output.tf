output "backup_job_config" {
  value = {
    rclone = var.backup_settings.enabled ? templatefile("${path.module}/templates/rclone.tpl", {
      region = data.aws_s3_bucket.backup[0].region
    }) : ""

    bucket = var.backup_settings.bucket_name

    annotations = {
      "iam.amazonaws.com/role" = aws_iam_role.backup[0].name
    }
  }
  sensitive = true
}
