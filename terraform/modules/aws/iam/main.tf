resource "aws_iam_service_linked_role" "autoscaling" {
  custom_suffix    = var.cluster_name
  aws_service_name = "autoscaling.amazonaws.com"
}

resource "aws_iam_role" "master" {
  name = "tf-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "kms_encryption" {
  count = var.kms_key_arn == "" ? 0 : 1

  policy_arn = aws_iam_policy.kms_encryption[0].arn
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "master_encrypted_ebs_attach" {
  count = var.kms_key_arn == "" ? 0 : 1

  policy_arn = aws_iam_policy.encrypted_ebs_attach[0].arn
  role       = aws_iam_role.master.name
}

resource "aws_iam_role" "node" {
  name = "tf-${var.cluster_name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "tf-${var.cluster_name}-node"
  role = aws_iam_role.node.name
}

resource "aws_iam_policy" "kms_encryption" {
  count = var.kms_key_arn == "" ? 0 : 1

  name_prefix = "kms-${var.cluster_name}"
  description = "EKS KMS Encryption policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.kms_encryption[0].json
}

resource "aws_iam_policy" "encrypted_ebs_attach" {
  count = var.kms_key_arn == "" ? 0 : 1

  name_prefix = "volume-attachment-${var.cluster_name}"
  description = "EKS cluster manager IAM encrypted EBS attachment policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.encrypted_ebs_attach[0].json
}

data "aws_iam_policy_document" "kms_encryption" {
  count = var.kms_key_arn == "" ? 0 : 1

  statement {
    sid    = "eksKmsEncryption"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
    ]
    resources = [var.kms_key_arn]
  }
}

data "aws_iam_policy_document" "encrypted_ebs_attach" {
  count = var.kms_key_arn == "" ? 0 : 1

  statement {
    sid    = "encryptedEbsAttachment"
    effect = "Allow"

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = [var.kms_key_arn]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = ["true"]
    }
  }
}

resource "aws_kms_grant" "kms_encrypt" {
  count = var.kms_key_arn == "" ? 0 : 1

  name              = "${var.cluster_name}_kms_encrypt"
  key_id            = basename(var.kms_key_arn)
  grantee_principal = aws_iam_service_linked_role.autoscaling.arn
  operations = [
    "Encrypt",
    "Decrypt",
    "ReEncryptTo",
    "ReEncryptFrom",
    "DescribeKey",
    "CreateGrant",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext"
  ]
}
