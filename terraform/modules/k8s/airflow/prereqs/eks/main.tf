locals {
  s3_syncer_name = "${var.cluster_name}-syncer"
}

########################################################
# AWS IAM User for DAGs syncer
########################################################

data "aws_iam_role" "node" {
  name = "tf-${var.cluster_name}-node"
}

data "aws_s3_bucket" "dags" {
  bucket = var.dag_bucket
}

data "aws_iam_policy_document" "syncer" {
  statement {
    #    actions   = ["s3:GetObject", "s3:ListBucket"]
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["${data.aws_s3_bucket.dags.arn}*"]
  }
  statement {
    actions   = ["ecr:*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "syncer" {
  name               = local.s3_syncer_name
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

resource "aws_iam_policy" "syncer" {
  name   = local.s3_syncer_name
  policy = data.aws_iam_policy_document.syncer.json
}

resource "aws_iam_policy_attachment" "syncer" {
  name       = local.s3_syncer_name
  roles      = [aws_iam_role.syncer.name]
  policy_arn = aws_iam_policy.syncer.arn
}


resource "aws_iam_user" "syncer" {
  name = local.s3_syncer_name
  path = "/odahuflow/"

  tags = {
    Name        = local.s3_syncer_name
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_user_policy" "syncer" {
  name   = "syncer"
  user   = aws_iam_user.syncer.name
  policy = data.aws_iam_policy_document.syncer.json
}

resource "aws_iam_access_key" "syncer" {
  user = aws_iam_user.syncer.name
}
