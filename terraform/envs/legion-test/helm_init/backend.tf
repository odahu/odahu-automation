terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "helm_init"
  }
}
