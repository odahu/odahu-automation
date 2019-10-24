terraform {
  backend "s3" {
    key = "eks_create/default.tfstate"
  }
}

