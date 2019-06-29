
output tls_secret_crt {
  value = "${data.aws_s3_bucket_object.tls-secret-key.body}"

}
output tls_secret_key {
  value = "${data.aws_s3_bucket_object.tls-secret-key.body}"
}
