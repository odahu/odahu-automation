terraform {
  source = "${path_relative_from_include()}/modules//${local.dns_provider}"

#  before_hook "setup_backend" {
#    commands = ["init"]
#
#    execute = [
#      "/bin/cp", "${get_terragrunt_dir()}/${path_relative_from_include()}/templates/backend/${local.cloud_type}.tf", "./backend.tf"
#    ]
#  }

#  before_hook "setup_provider" {
#    commands = ["init"]

#    execute = [
#      "/bin/cp", "${get_terragrunt_dir()}/${path_relative_from_include()}/templates/provider/${local.dns_provider}.tf", "./${local.dns_provider}_provider.tf"
#    ]
#  }

#  before_hook "setup_backend_provider" {
#    commands = ["init"]

#    execute = [
#      "/bin/cp", "${get_terragrunt_dir()}/${path_relative_from_include()}/templates/provider/${local.cloud_type}.tf", "./${local.cloud_type}_provider.tf"
#    ]
#  }
}

locals {
  profile        = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config         = jsondecode(file(local.profile))
  cloud_type     = local.config.cloud_type
  dns_provider   = lookup(local.config, "dns_provider", "gcp")
  records        = lookup(local.config, "dns_records", get_env("TF_VAR_records", "[]"))
}

inputs = {
  records              = local.records,
  tfstate_bucket       = local.config.tfstate_bucket,
  managed_zone         = lookup(local.config, "dns_zone_name", ""),
  aws_region           = lookup(local.config, "aws_region", ""),
  domain               = lookup(local.config, "domain", ""),
  project_id           = lookup(local.config, "project_id", ""),
  resource_group_name  = lookup(local.config, "azure_resource_group", ""),
  storage_account_name = lookup(local.config, "azure_storage_account", "")
}
