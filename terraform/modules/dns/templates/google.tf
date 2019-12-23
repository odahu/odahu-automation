provider "google" {
  version = "2.20.0"
}

terraform {
  backend "gcs" {
    prefix = "/odahu_dns"
  }
}

