provider "google" {
  version = "2.20.1"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

provider "google-beta" {
  version = "2.20.1"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

provider "random" {
  version = "2.2.1"
}

provider "local" {
  version = "1.4.0"
}

provider "null" {
  version = "2.1.2"
}

provider "tls" {
  version = "2.1.1"
}
