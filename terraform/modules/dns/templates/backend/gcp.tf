terraform {
  backend "gcs" {
    prefix = "/odahu_dns"
  }
}

