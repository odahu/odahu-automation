include {
  path = "../../../../modules/dns/terragrunt.hcl"
}

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))
}

remote_state {
  backend = "s3"
  config = {
    bucket = local.config.tfstate_bucket
    region = local.config.aws_region
    key    = "odahu_dns"
  }
}
