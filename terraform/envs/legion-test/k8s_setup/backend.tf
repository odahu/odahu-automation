terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "k8s_setup"
  }
}
