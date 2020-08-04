data "aws_s3_bucket" "backup" {
  count  = var.backup_settings.enabled ? 1 : 0
  bucket = var.backup_settings.bucket_name
}

data "aws_iam_role" "node" {
  count = var.backup_settings.enabled ? 1 : 0
  name  = "tf-${var.cluster_name}-node"
}

data "aws_iam_policy_document" "backup" {
  count = var.backup_settings.enabled ? 1 : 0
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "${data.aws_s3_bucket.backup[0].arn}*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_role" "backup" {
  count = var.backup_settings.enabled ? 1 : 0
  name  = "${var.cluster_name}-backup"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      },
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": "${data.aws_iam_role.node[0].arn}"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "backup" {
  count  = var.backup_settings.enabled ? 1 : 0
  name   = "${var.cluster_name}-backup"
  policy = data.aws_iam_policy_document.backup[0].json
}

resource "aws_iam_policy_attachment" "backup" {
  count = var.backup_settings.enabled ? 1 : 0
  name  = "${var.cluster_name}-backup"
  roles = [aws_iam_role.backup[0].name]

  policy_arn = aws_iam_policy.backup[0].arn
}

resource "aws_iam_user" "backup" {
  count = var.backup_settings.enabled ? 1 : 0
  name  = "${var.cluster_name}-backup"
  path  = "/odahuflow/"
  tags = {
    Name        = "${var.cluster_name}-backup"
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_user_policy" "backup" {
  count  = var.backup_settings.enabled ? 1 : 0
  name   = "backup"
  user   = aws_iam_user.backup[0].name
  policy = data.aws_iam_policy_document.backup[0].json
}

resource "aws_iam_access_key" "backup" {
  count = var.backup_settings.enabled ? 1 : 0
  user  = aws_iam_user.backup[0].name
}
