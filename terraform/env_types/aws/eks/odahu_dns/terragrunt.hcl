terraform_version_constraint = ">= 0.12.21"

include {
  path = "../../../../modules/dns/terragrunt.hcl"
}

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  aws_region = lookup(lookup(local.config.cloud, "aws", {}), "region", "eu-central-1")
}

remote_state {
  backend = "s3"
  config = {
    bucket = local.config.tfstate_bucket.tfstate_bucket_name
    region = local.aws_region
    key    = "${basename(get_terragrunt_dir())}/default.tfstate"
  }
}
