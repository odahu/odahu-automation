data "external" "env" {
  program = ["jq", "-n", "env"]
}

locals {
  gcp_credentials = substr(data.external.env.result.GOOGLE_CREDENTIALS, 0, 1) == "{" ? jsondecode(data.external.env.result.GOOGLE_CREDENTIALS) : jsondecode(file(data.external.env.result.GOOGLE_CREDENTIALS))
  gcp_project_id  = var.gcp_project_id == "" ? local.gcp_credentials.project_id : var.gcp_project_id
  node_version    = var.node_version == "" ? var.k8s_version : var.node_version
  bastion_tags    = length(var.bastion_tags) == 0 ? [ "${var.cluster_name}-bastion" ] : var.bastion_tags
  gke_node_tags   = length(var.gke_node_tags) == 0 ? [ "${var.cluster_name}-gke-node" ] : var.gke_node_tags
}
