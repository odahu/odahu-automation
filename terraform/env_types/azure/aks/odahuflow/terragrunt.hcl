terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  resource_group  = lookup(lookup(local.config.cloud, "azure", {}), "resource_group", "")
  location        = lookup(lookup(local.config.cloud, "azure", {}), "location", "")
  storage_account = lookup(lookup(local.config.cloud, "azure", {}), "storage_account", "")

  config_context_auth_info = lookup(local.config, "config_context_auth_info", "")
  config_context_cluster   = lookup(local.config, "config_context_cluster", "")
  cluster_name             = lookup(local.config, "cluster_name", "odahuflow")
  cluster_domain_name      = lookup(local.config.dns, "domain", null)

  cmd_k8s_config_fetch = "az aks get-credentials --overwrite-existing --name \"${local.cluster_name}\" --resource-group \"${local.resource_group}\""
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

  before_hook "k8s_config_fetch" {
    commands = ["destroy"]
    execute  = ["bash", "-c", local.cmd_k8s_config_fetch]
  }
}

inputs = {
  azure_location        = local.location
  azure_resource_group  = local.resource_group
  azure_storage_account = local.storage_account

  cluster_domain_name = local.cluster_domain_name

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}
