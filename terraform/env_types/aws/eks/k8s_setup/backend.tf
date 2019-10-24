terraform {
  backend "s3" {
    key = "k8s_setup/default.tfstate"
  }
}
