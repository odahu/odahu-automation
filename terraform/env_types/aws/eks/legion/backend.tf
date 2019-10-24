terraform {
  backend "s3" {
    key = "legion/default.tfstate"
  }
}
