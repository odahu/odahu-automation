provider "aws" {
  version = "2.33.0"
  region  = var.aws_region
}

provider "local" {
  version = "1.4.0"
}

provider "null" {
  version = "2.1.2"
}

provider "template" {
  version = "2.1.2"
}
