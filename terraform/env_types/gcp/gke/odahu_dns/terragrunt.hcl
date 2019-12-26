include {
  path = "../../../../modules/dns/terragrunt.hcl"
}

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))
}

remote_state {
  backend = "gcs"
  config = {
    bucket = local.config.tfstate_bucket
    prefix = "odahu_dns"
  }
}
