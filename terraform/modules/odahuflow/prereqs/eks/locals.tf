locals {
  log_bucket        = var.log_bucket == "" ? aws_s3_bucket.data.id : aws_s3_bucket.logs[0].id
  log_bucket_region = var.log_bucket == "" ? aws_s3_bucket.data.region : aws_s3_bucket.logs[0].region
}

