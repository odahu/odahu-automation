output "backup_job_config" {
  value = {
    rclone = var.backup_settings.enabled ? templatefile("${path.module}/templates/rclone.tpl", {
      backup_sa_key = jsonencode(jsondecode(base64decode(google_service_account_key.backup_sa[0].private_key)))
    }) : ""

    bucket = var.backup_settings.bucket_name

    annotations = {}
  }
  sensitive = true
}
