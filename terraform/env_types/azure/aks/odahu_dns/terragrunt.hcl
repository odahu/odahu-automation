terraform_version_constraint = ">= 0.12.21"

include {
  path = "../../../../modules/dns/terragrunt.hcl"
}

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  resource_group  = lookup(lookup(local.config.cloud, "azure", {}), "resource_group", "")
  storage_account = lookup(lookup(local.config.cloud, "azure", {}), "storage_account", "")
}

remote_state {
  backend = "azurerm"
  config = {
    container_name       = local.config.tfstate_bucket.tfstate_bucket_name
    resource_group_name  = local.resource_group
    storage_account_name = local.storage_account
    key                  = "${basename(get_terragrunt_dir())}/default.tfstate"
  }
}
