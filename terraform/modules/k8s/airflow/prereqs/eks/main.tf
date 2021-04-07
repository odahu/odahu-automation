locals {
  s3_syncer_name = "${var.cluster_name}-syncer"
}

data "aws_s3_bucket" "dags" {
  bucket = var.dag_bucket
}

########################################################
# AWS IAM User for DAGs syncer
########################################################

data "aws_iam_policy_document" "syncer_base" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_provider.url, "https://", "")}:sub"
      values   = var.syncer_sa_list
    }

    principals {
      identifiers = [var.openid_connect_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "syncer" {
  assume_role_policy = data.aws_iam_policy_document.syncer_base.json
  name               = "${var.cluster_name}-syncer"
}

data "aws_iam_policy_document" "syncer" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    effect    = "Allow"
    resources = ["${data.aws_s3_bucket.dags.arn}*"]
  }
  statement {
    actions   = ["ecr:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn == "" ? [] : [var.kms_key_arn]
    iterator = key_arn
    content {
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      effect    = "Allow"
      resources = [key_arn]
    }
  }
}

resource "aws_iam_policy" "syncer" {
  name   = local.s3_syncer_name
  policy = data.aws_iam_policy_document.syncer.json
}

resource "aws_iam_role_policy_attachment" "syncer" {
  policy_arn = aws_iam_policy.syncer.arn
  role       = aws_iam_role.syncer.name
}
