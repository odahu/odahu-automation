########################################################
# S3 data bucket
########################################################

resource "aws_s3_bucket" "data" {
  bucket        = var.data_bucket
  acl           = "private"
  region        = var.region
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = basename(var.kms_key_arn)
        sse_algorithm     = "aws:kms"
      }
    }
  }

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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = basename(var.kms_key_arn)
        sse_algorithm     = "aws:kms"
      }
    }
  }

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
    actions = [
      "s3:ListBucket",
      "s3:*Object"
    ]
    effect    = "Allow"
    resources = var.log_bucket == "" ? ["${aws_s3_bucket.data.arn}*"] : ["${aws_s3_bucket.logs[0].arn}*"]
  }

  statement {
    actions   = ["ecr:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    effect    = "Allow"
    resources = [var.kms_key_arn]
  }
}

data "aws_iam_policy_document" "collector_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_provider.url, "https://", "")}:sub"
      values   = var.collector_sa_list
    }

    principals {
      identifiers = [var.openid_connect_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "collector" {
  assume_role_policy = data.aws_iam_policy_document.collector_assume.json
  name               = "${var.cluster_name}-collector"
}

resource "aws_iam_policy" "collector" {
  name   = "${var.cluster_name}-collector"
  policy = data.aws_iam_policy_document.collector.json
}

resource "aws_iam_role_policy_attachment" "collector" {
  policy_arn = aws_iam_policy.collector.arn
  role       = aws_iam_role.collector.name
}

resource "aws_iam_user" "collector" {
  name = "${var.cluster_name}-collector"
  path = "/odahuflow/"

  tags = {
    Name        = "${var.cluster_name}-collector"
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_user_policy_attachment" "collector" {
  user       = aws_iam_user.collector.name
  policy_arn = aws_iam_policy.collector.arn
}

resource "aws_iam_access_key" "collector" {
  user = aws_iam_user.collector.name
}
