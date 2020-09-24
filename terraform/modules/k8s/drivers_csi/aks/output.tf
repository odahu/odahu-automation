output "installed" {
  value = kubernetes_storage_class.odahu
}

output "storage_class" {
  value = var.storage_class_name
}
