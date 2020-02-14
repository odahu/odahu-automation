terraform {
  source = "${path_relative_from_include()}/modules//${local.dns_provider}"
}

locals {
  profile         = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config          = jsondecode(file(local.profile))
  cloud_type      = local.config.cloud_type
  dns_provider    = lookup(local.config.dns, "provider", "gcp")
  records         = lookup(local.config.dns, "records", get_env("TF_VAR_records", "[]"))
  gcp_project_id  = lookup(local.config.dns, "project_id", lookup(local.config, "project_id", ""))
  gcp_credentials = jsonencode(lookup(local.config.dns, "credentials", {}))
}

inputs = {
  records              = local.records,
  tfstate_bucket       = local.config.tfstate_bucket,
  managed_zone         = lookup(local.config.dns, "zone_name", ""),
  aws_region           = lookup(local.config, "aws_region", ""),
  domain               = lookup(local.config.dns, "domain", ""),
  gcp_project_id       = local.gcp_project_id,
  gcp_credentials      = local.gcp_credentials
  resource_group_name  = lookup(local.config, "azure_resource_group", ""),
  storage_account_name = lookup(local.config, "azure_storage_account", "")
}

