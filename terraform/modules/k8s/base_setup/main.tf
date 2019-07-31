provider "google" {
  version = "~> 2.2"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

provider "aws" {
  version                 = "2.13"
  region                  = var.region_aws
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

########################################################
# K8S Cluster Setup
########################################################
data "aws_s3_bucket_object" "tls-secret-key" {
  bucket = var.secrets_storage
  key    = "${var.cluster_name}/tls/${var.cluster_name}.key"
}

data "aws_s3_bucket_object" "tls-secret-crt" {
  bucket = var.secrets_storage
  key    = "${var.cluster_name}/tls/${var.cluster_name}.fullchain.crt"
}

# Install TLS cert as a secret
resource "kubernetes_secret" "tls_default" {
  count = length(var.tls_namespaces)
  metadata {
    name      = "${var.cluster_name}-tls"
    namespace = element(var.tls_namespaces, count.index)
  }
  data = {
    "tls.key" = data.aws_s3_bucket_object.tls-secret-key.body
    "tls.crt" = data.aws_s3_bucket_object.tls-secret-crt.body
  }
  type = "kubernetes.io/tls"
}

