locals {
  argo_sa_name        = "${var.cluster_name}-argo"
  workflows_namespace = var.workflows_namespace == "" ? var.namespace : var.workflows_namespace
}

data "aws_s3_bucket" "argo" {
  bucket = var.bucket
}

data "aws_iam_policy_document" "argo_base" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_provider.url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.namespace}:argo-server",
        "system:serviceaccount:${local.workflows_namespace}:argo-workflow"
      ]
    }

    principals {
      identifiers = [var.openid_connect_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "argo" {
  assume_role_policy = data.aws_iam_policy_document.argo_base.json
  name               = "${var.cluster_name}-argo"
}

data "aws_iam_policy_document" "argo" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    effect    = "Allow"
    resources = ["${data.aws_s3_bucket.argo.arn}*"]
  }
  statement {
    actions   = ["ecr:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    effect    = "Allow"
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_policy" "argo" {
  name   = local.argo_sa_name
  policy = data.aws_iam_policy_document.argo.json
}

resource "aws_iam_role_policy_attachment" "argo" {
  policy_arn = aws_iam_policy.argo.arn
  role       = aws_iam_role.argo.name
}
