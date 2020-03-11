terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  resource_group  = lookup(lookup(local.config.cloud, "azure", {}), "resource_group", "")
  storage_account = lookup(lookup(local.config.cloud, "azure", {}), "storage_account", "")

  config_context_auth_info = lookup(local.config, "config_context_auth_info", "")
  config_context_cluster   = lookup(local.config, "config_context_cluster", "")
  cluster_domain_name      = lookup(local.config.dns, "domain", null)
}

remote_state {
  backend = "azurerm"
  config = {
    container_name       = local.config.tfstate_bucket
    resource_group_name  = local.resource_group
    storage_account_name = local.storage_account
    key                  = "${basename(get_terragrunt_dir())}/default.tfstate"
  }
}

terraform {
  extra_arguments "common_args" {
    commands = [
      "init",
      "apply",
      "plan",
      "destroy"
    ]
    arguments = ["-no-color", "-compact-warnings"]
  }
}

inputs = {
  azure_resource_group = local.resource_group
  cluster_domain_name  = local.cluster_domain_name

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}
