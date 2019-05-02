# output "client_certificate" {
#   value = "${google_container_cluster.cluster.master_auth.0.client_certificate}"
# }

# output "client_key" {
#   value = "${google_container_cluster.cluster.master_auth.0.client_key}"
# }

output "cluster_ca_certificate" {
  value = "${google_container_cluster.cluster.master_auth.0.cluster_ca_certificate}"
}

output "cluster_endpoint" {
  value = "${google_container_cluster.cluster.endpoint}"
}

output kubectl_setup_command {
  value = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project_id}"
}

output bastion_address {
  value = "bastion.${var.cluster_name}.${var.root_domain}"
}
 
output k8s_api_address {
  value = "api.${var.cluster_name}.${var.root_domain}"
}

output ssh_key {
  value = "file(data.google_storage_bucket_object.ssh_public_key.self_link)"
}