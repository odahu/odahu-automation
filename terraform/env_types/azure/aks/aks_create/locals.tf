locals {
  common_tags = merge(
    {
      "cluster" = var.cluster_name,
      "project" = "odahu-flow"
    },
    var.aks_common_tags,
    var.node_labels
  )

  aks_dns_prefix = var.aks_dns_prefix == "" ? var.cluster_name : var.aks_dns_prefix
}
