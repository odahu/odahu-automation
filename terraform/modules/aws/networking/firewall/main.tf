data "aws_eip" "nat" {
  filter {
    name   = "tag:Name"
    values = [var.cluster_name]
  }
}

# Firewall rule that allows internal communication across all protocols
resource "aws_security_group" "master" {
  name        = "tf-${var.cluster_name}-master"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group_rule" "api-https-external" {
  cidr_blocks       = var.allowed_ips
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.master.id
  to_port           = 443
  type              = "ingress"
}

# Node

resource "aws_security_group" "node" {
  name        = "tf-${var.cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "tf-${var.cluster_name}",
    "kubernetes.io/cluster/${var.cluster_name}" = "owned",
  }
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-dns" {
  description              = "Allow node to communicate with each other"
  from_port                = 53
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.node.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-dns-ephemeral" {
  description              = "Allow node to communicate with each other"
  from_port                = 1025
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.node.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-bastion" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-lb" {
  description              = "Allow LB"
  from_port                = 30000
  to_port                  = 30001
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.lb.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.master.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  to_port                  = 443
  type                     = "ingress"
}

# Bastion

resource "aws_security_group" "bastion" {
  name        = "tf-${var.cluster_name}-bastion"
  description = "Bastion connection"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-bastion"
  }
}

resource "aws_security_group_rule" "bastion-ssh" {
  cidr_blocks       = var.allowed_ips
  description       = "Allow EPAM networks to connect bastion via SSH"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  to_port           = 22
  type              = "ingress"
}

# Balancer
resource "aws_security_group" "lb" {
  name        = "tf-${var.cluster_name}-lb"
  description = "LB connection"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-lb"
  }
}

resource "aws_security_group_rule" "lb-https" {
  cidr_blocks       = concat(var.allowed_ips, ["${data.aws_eip.nat.public_ip}/32"])
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
}

resource "aws_security_group_rule" "lb-http" {
  cidr_blocks       = concat(var.allowed_ips, ["${data.aws_eip.nat.public_ip}/32"])
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
}

