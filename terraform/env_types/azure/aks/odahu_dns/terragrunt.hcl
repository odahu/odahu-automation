include {
  path = "../../../../modules/dns/terragrunt.hcl"
}

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))
}

remote_state {
  backend = "azurerm"
  config = {
    key                  = "odahu_dns"
    container_name       = local.config.tfstate_bucket
    resource_group_name  = local.config.azure_resource_group
    storage_account_name = local.config.azure_storage_account
  }
}
