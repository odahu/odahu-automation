output "autoscaler_role_arn" {
  value = aws_iam_role.autoscaler.arn
}

output "autoscaler_role_id" {
  value = aws_iam_role.autoscaler.id
}

output "openid_connect_provider" {
  value = {
    url = aws_iam_openid_connect_provider.this.url,
    arn = aws_iam_openid_connect_provider.this.arn
  }
}
