data "external" "env" {
  program = ["jq", "-n", "env"]
}

locals {
  sp_client_id = data.external.env.result.ARM_CLIENT_ID
  sp_secret    = data.external.env.result.ARM_CLIENT_SECRET

  common_tags = merge(
    {
      "cluster" = var.cluster_name,
      "project" = "odahu-flow"
    },
    var.aks_common_tags
  )

  aks_dns_prefix = var.aks_dns_prefix == "" ? var.cluster_name : var.aks_dns_prefix
  bastion_tags   = var.bastion_labels == "" ? local.common_tags : var.bastion_labels
}
