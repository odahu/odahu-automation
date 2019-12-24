variable "aws_region" {}

provider "aws" {
  version = "2.33.0"
  region  = var.aws_region
}
