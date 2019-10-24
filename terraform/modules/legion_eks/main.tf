data "aws_caller_identity" "current" {}
data "aws_iam_role" "node" {
  name = "tf-${var.cluster_name}-node"
}

########################################################
# S3 bucket
########################################################

resource "aws_s3_bucket" "this" {
  bucket        = var.legion_data_bucket
  acl           = "private"
  region        = var.region
  force_destroy = true

  tags = {
    Name = var.legion_data_bucket
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
    resources = ["${aws_s3_bucket.this.arn}*"]
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
  roles      = ["${aws_iam_role.collector.name}"]
  policy_arn = "${aws_iam_policy.collector.arn}"
}


resource "aws_iam_user" "collector" {
  name = "${var.cluster_name}-collector"
  path = "/legion/"

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
  user = "${aws_iam_user.collector.name}"
}
