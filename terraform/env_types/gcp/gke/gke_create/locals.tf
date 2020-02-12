locals {
  bastion_gcp_tags = length(var.bastion_gcp_tags) == 0 ? ["${var.cluster_name}-bastion"] : var.bastion_gcp_tags
  node_gcp_tags    = length(var.node_gcp_tags) == 0 ? ["${var.cluster_name}-gke-node"] : var.node_gcp_tags
}
