terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  sp_client_id = get_env("ARM_CLIENT_ID", "")
  sp_secret    = get_env("ARM_CLIENT_SECRET", "")

  cluster_name    = lookup(local.config, "cluster_name", "odahuflow")
  resource_group  = lookup(lookup(local.config.cloud, "azure", {}), "resource_group", "")
  location        = lookup(lookup(local.config.cloud, "azure", {}), "location", "")
  storage_account = lookup(lookup(local.config.cloud, "azure", {}), "storage_account", "")

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
    arguments = [
      "-no-color",
      "-compact-warnings"
    ]
  }

  after_hook "k8s_config_fetch" {
    commands     = ["apply"]
    execute      = ["bash", "-c", local.cmd_k8s_config_fetch]
    run_on_error = false
  }
}

inputs = {
  azure_location       = local.location
  azure_resource_group = local.resource_group
  aks_sp_client_id     = local.sp_client_id
  aks_sp_secret        = local.sp_secret
}
