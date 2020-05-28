output "storage_class" {
  value = kubernetes_storage_class.sc.metadata[0].name
}
