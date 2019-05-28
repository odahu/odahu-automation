terraform {
  backend "local" {
    path = "../../../../_tfstate/legion-test-helm.tfstate"
  }
}