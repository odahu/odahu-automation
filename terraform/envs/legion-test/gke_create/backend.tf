terraform {
  backend "local" {
    path = "../../../../_tfstate/legion-test-gke.tfstate"
  }
}