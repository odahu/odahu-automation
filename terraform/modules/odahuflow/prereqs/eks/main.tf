########################################################
# S3 data bucket
########################################################

resource "aws_s3_bucket" "data" {
  bucket        = var.data_bucket
  acl           = "private"
  region        = var.region
  force_destroy = true

  dynamic "server_side_encryption_configuration" {
    for_each = var.kms_key_arn == "" ? [] : [var.kms_key_arn]
    iterator = key_arn
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = basename(key_arn.value)
          sse_algorithm     = "aws:kms"
        }
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
# S3 MLFlow artifacts bucket
########################################################

resource "aws_s3_bucket" "mlflow" {
  bucket        = local.mlflow_bucket_name
  acl           = "private"
  region        = var.region
  force_destroy = true

  dynamic "server_side_encryption_configuration" {
    for_each = var.kms_key_arn == "" ? [] : [var.kms_key_arn]
    iterator = key_arn
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = basename(key_arn.value)
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  tags = {
    Name = local.mlflow_bucket_name
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

  dynamic "server_side_encryption_configuration" {
    for_each = var.kms_key_arn == "" ? [] : [var.kms_key_arn]
    iterator = key_arn
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = basename(key_arn.value)
          sse_algorithm     = "aws:kms"
        }
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
      "s3:*Object",
      "s3:GetObjectACL",
    ]
    effect    = "Allow"
    resources = var.log_bucket == "" ? ["${aws_s3_bucket.data.arn}/*"] : ["${aws_s3_bucket.logs[0].arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:CreateBucket"
    ]
    effect    = "Allow"
    resources = var.log_bucket == "" ? ["${aws_s3_bucket.data.arn}"] : ["${aws_s3_bucket.logs[0].arn}"]
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
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      effect    = "Allow"
      resources = [key_arn.value]
    }
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

########################################################
# AWS IAM User for Jupyterhub
########################################################

data "aws_iam_policy_document" "jupyter_notebook_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_provider.url, "https://", "")}:sub"
      values   = var.jupyter_notebook_sa_list
    }

    principals {
      identifiers = [var.openid_connect_provider.arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "jupyter_notebook" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketLocation",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    effect    = "Allow"
    resources = var.log_bucket == "" ? ["${aws_s3_bucket.data.arn}/*"] : ["${aws_s3_bucket.logs[0].arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    effect    = "Allow"
    resources = var.log_bucket == "" ? ["${aws_s3_bucket.data.arn}"] : ["${aws_s3_bucket.logs[0].arn}"]
  }

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn == "" ? [] : [var.kms_key_arn]
    iterator = key_arn
    content {
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      effect    = "Allow"
      resources = [key_arn.value]
    }
  }
}

resource "aws_iam_role" "jupyter_notebook" {
  assume_role_policy = data.aws_iam_policy_document.jupyter_notebook_assume.json
  name               = "${var.cluster_name}-jupyter-notebook"
}

resource "aws_iam_policy" "jupyter_notebook" {
  name   = "${var.cluster_name}-jupyter-notebook"
  policy = data.aws_iam_policy_document.jupyter_notebook.json
}

resource "aws_iam_role_policy_attachment" "jupyter_notebook" {
  policy_arn = aws_iam_policy.jupyter_notebook.arn
  role       = aws_iam_role.jupyter_notebook.name
}

resource "aws_iam_user" "jupyter_notebook" {
  name = "${var.cluster_name}-jupyter-notebook"
  path = "/odahuflow/"

  tags = {
    Name        = "${var.cluster_name}-jupyter-notebook"
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_access_key" "jupyterhub" {
  user = aws_iam_user.jupyter_notebook.name
}

########################################################
# AWS IAM User for MLFlow
########################################################

data "aws_iam_policy_document" "mlflow_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:odahu-flow/mlflow",
                  "system:serviceaccount:odahu-flow-training/default"]
    }

    principals {
      identifiers = [var.openid_connect_provider.arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "mlflow" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketLocation",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.mlflow.arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.mlflow.arn}"]
  }

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn == "" ? [] : [var.kms_key_arn]
    iterator = key_arn
    content {
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      effect    = "Allow"
      resources = [key_arn.value]
    }
  }
}

resource "aws_iam_role" "mlflow" {
  assume_role_policy = data.aws_iam_policy_document.mlflow_assume.json
  name               = local.mlflow_iam_name
}

resource "aws_iam_policy" "mlflow" {
  name   = local.mlflow_iam_name
  policy = data.aws_iam_policy_document.mlflow.json
}

resource "aws_iam_role_policy_attachment" "mlflow" {
  policy_arn = aws_iam_policy.mlflow.arn
  role       = aws_iam_role.mlflow.name
}

resource "aws_iam_user" "mlflow" {
  name = local.mlflow_iam_name
  path = "/odahuflow/"

  tags = {
    Name        = local.mlflow_iam_name
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_access_key" "mlflow" {
  user = aws_iam_user.mlflow.name
}
