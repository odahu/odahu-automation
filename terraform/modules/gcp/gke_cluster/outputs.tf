output "cluster_endpoint" {
  value = google_container_cluster.cluster.endpoint
}

output "kubectl_setup_command" {
  value = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project_id}"
}

output "bastion_address" {
  value = var.bastion_enabled ? google_compute_instance.gke_bastion[0].network_interface[0].access_config[0].nat_ip : null
}

output "k8s_api_address" {
  value = google_container_cluster.cluster.endpoint
}

output "k8s_pods_cidr" {
  value = var.pods_cidr
}
