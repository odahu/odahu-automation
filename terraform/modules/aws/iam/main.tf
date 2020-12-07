resource "aws_iam_service_linked_role" "autoscaling" {
  custom_suffix    = "${var.cluster_name}"
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
  policy_arn = aws_iam_policy.kms_encryption.arn
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "master_encrypted_ebs_attach" {
  policy_arn = aws_iam_policy.encrypted_ebs_attach.arn
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
        "Service": "ec2.amazonaws.com",
        "Service": "autoscaling.amazonaws.com"
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

resource "aws_iam_role_policy_attachment" "node_autoscaling" {
  policy_arn = aws_iam_policy.node_autoscaling.arn
  role       = aws_iam_role.node.name
}

resource "aws_iam_policy" "node_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${var.cluster_name}"
  description = "EKS worker node autoscaling policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.node_autoscaling.json
}

data "aws_iam_policy_document" "node_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "kms_encryption" {
  name_prefix = "kms-${var.cluster_name}"
  description = "EKS KMS Encryption policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.kms_encryption.json
}

resource "aws_iam_policy" "encrypted_ebs_attach" {
  name_prefix = "volume-attachment-${var.cluster_name}"
  description = "EKS cluster manager IAM encrypted EBS attachment policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.encrypted_ebs_attach.json
}

data "aws_iam_policy_document" "kms_encryption" {
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
