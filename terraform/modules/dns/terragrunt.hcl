terraform {
  source = "${path_relative_from_include()}/modules//${local.config.dns_provider}"

  before_hook "backend" {
    commands = ["init"]

    execute = [
      "/bin/cp", "${get_terragrunt_dir()}/${path_relative_from_include()}/templates/${local.config.dns_provider}.tf", "./backend.tf"
    ]
  }

  extra_arguments "init_vars" {
    commands = [
      "init"
    ]

    arguments = [
      "-backend-config=bucket=${local.config.tfstate_bucket}",
    ]
  }
}

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))
  records = lookup(local.config, "dns_records", get_env("TF_VAR_records", "[]"))
}

inputs = {
  records        = local.records,
  tfstate_bucket = local.config.tfstate_bucket,
  managed_zone   = lookup(local.config, "dns_zone_name", ""),
  region         = lookup(local.config, "aws_region", ""),
  domain         = lookup(local.config, "domain", ""),
  project_id     = local.config.project_id
}
