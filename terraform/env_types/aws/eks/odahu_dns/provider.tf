provider "aws" {
  version = "2.33.0"
  region  = var.aws_region
}

provider "google" {
  version     = "2.20.1"
  project     = var.gcp_project_id
  credentials = var.gcp_credentials
}

provider "null" {
  version = "2.1.2"
}
