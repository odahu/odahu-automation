provider "google" {
  version = "2.20.1"
  region  = var.gcp_region
  zone    = var.gcp_zone
  project = local.gcp_project_id
}

provider "google-beta" {
  version = "2.20.1"
  region  = var.gcp_region
  zone    = var.gcp_zone
  project = local.gcp_project_id
}

provider "external" {
  version = "~> 1.2"
}

provider "random" {
  version = "~> 2.2.0"
}

provider "local" {
  version = "~> 1.3.0"
}

provider "null" {
  version = "~> 2.1.2"
}

provider "tls" {
  version = "~> 2.1.0"
}
