data "aws_caller_identity" "current" {}
data "aws_iam_role" "node" {
  name = "tf-${var.cluster_name}-node"
}

########################################################
# S3 data bucket
########################################################

resource "aws_s3_bucket" "data" {
  bucket        = var.data_bucket
  acl           = "private"
  region        = var.region
  force_destroy = true

  dynamic "lifecycle_rule" {
    for_each = var.log_bucket == "" ? [1] : []
    content {
      id      = "${var.cluster_name}-logs"
      enabled = true
      prefix  = "logs/"

      tags = {
        "rule"      = "${var.cluster_name}-logs"
        "autoclean" = "true"
      }

      expiration {
        days = var.log_expiration_days
      }
    }
  }

  tags = {
    Name = var.data_bucket
    Env  = var.cluster_name
  }
}

########################################################
# S3 logs bucket
########################################################

resource "aws_s3_bucket" "logs" {
  count = var.log_bucket == "" ? 0 : 1

  bucket        = var.log_bucket
  acl           = "private"
  region        = var.region
  force_destroy = true

  lifecycle_rule {
    id      = "${var.cluster_name}-logs"
    enabled = true

    prefix = "logs/"

    tags = {
      "rule"      = "${var.cluster_name}-logs"
      "autoclean" = "true"
    }

    expiration {
      days = var.log_expiration_days
    }
  }

  tags = {
    Name = var.log_bucket
    Env  = var.cluster_name
  }
}

resource "aws_ecr_repository" "this" {
  name = var.cluster_name
}

########################################################
# AWS IAM User for Fluentd
########################################################

data "aws_iam_policy_document" "collector" {
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = var.log_bucket == "" ? ["${aws_s3_bucket.data.arn}*"] : ["${aws_s3_bucket.logs[0].arn}*"]
  }

  statement {
    actions   = ["ecr:*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "collector" {
  name               = "${var.cluster_name}-collector"
  assume_role_policy = <<EOF
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
        "AWS": "${data.aws_iam_role.node.arn}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "collector" {
  name   = "${var.cluster_name}-collector"
  policy = data.aws_iam_policy_document.collector.json
}

resource "aws_iam_policy_attachment" "collector" {
  name       = "${var.cluster_name}-collector"
  roles      = [aws_iam_role.collector.name]
  policy_arn = aws_iam_policy.collector.arn
}


resource "aws_iam_user" "collector" {
  name = "${var.cluster_name}-collector"
  path = "/odahuflow/"

  tags = {
    Name        = "${var.cluster_name}-collector"
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_user_policy" "collector" {
  name   = "collector"
  user   = aws_iam_user.collector.name
  policy = data.aws_iam_policy_document.collector.json
}

resource "aws_iam_access_key" "collector" {
  user = aws_iam_user.collector.name
}
