output "helm_chart" {
  value = helm_release.monitoring
}

output "namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].annotations.name
}
