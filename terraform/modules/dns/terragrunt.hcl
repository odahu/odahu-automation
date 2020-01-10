terraform {
  source = "${path_relative_from_include()}/modules//${local.dns_provider}"
}

locals {
  profile        = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config         = jsondecode(file(local.profile))
  cloud_type     = local.config.cloud_type
  dns_provider   = lookup(local.config, "dns_provider", "gcp")
  records        = lookup(local.config, "dns_records", get_env("TF_VAR_records", "[]"))
  project_id     = lookup(local.config, "dns_project_id", lookup(local.config, "project_id", ""))
}

inputs = {
  records              = local.records,
  tfstate_bucket       = local.config.tfstate_bucket,
  managed_zone         = lookup(local.config, "dns_zone_name", ""),
  aws_region           = lookup(local.config, "aws_region", ""),
  domain               = lookup(local.config, "domain", ""),
  project_id           = local.project_id,
  resource_group_name  = lookup(local.config, "azure_resource_group", ""),
  storage_account_name = lookup(local.config, "azure_storage_account", "")
}
