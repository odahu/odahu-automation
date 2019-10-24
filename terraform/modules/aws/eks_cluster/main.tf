data "template_file" "aws_auth_cm" {
  template = "${file("${path.module}/templates/aws-auth-cm.tpl")}"
  vars = {
    node_role_arn = var.node_role_arn
  }
}

data "template_file" "cluster_autoscaler" {
  template = "${file("${path.module}/templates/cluster-autoscaler.tpl")}"
  vars = {
    cluster_name  = var.cluster_name
    k8s_version   = var.autoscaler_version
    cpu_max_limit = var.cluster_autoscaling_cpu_max_limit
    mem_max_limit = var.cluster_autoscaling_memory_max_limit
  }
}

resource "local_file" "aws_auth_cm" {
  content  = data.template_file.aws_auth_cm.rendered
  filename = "/tmp/aws_auth_cm.yml"
}

resource "local_file" "cluster_autoscaler" {
  content  = data.template_file.cluster_autoscaler.rendered
  filename = "/tmp/cluster_autoscaler.yml"
}

########################################################
# Bastion
########################################################
resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_machine_type
  key_name                    = var.cluster_name
  associate_public_ip_address = true
  subnet_id                   = var.nat_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]

  tags = {
    Name = "${var.cluster_name}-bastion"
  }

  user_data = "sed -i '/AllowAgentForwarding/s/^#//g' /etc/ssh/sshd_config && service sshd restart"
}

########################################################
# EKS Cluster
########################################################

resource "aws_eks_cluster" "default" {
  name     = "${var.cluster_name}"
  role_arn = var.master_role_arn
  version  = var.k8s_version

  vpc_config {
    security_group_ids = [var.master_sg_id]
    subnet_ids         = var.subnet_ids
  }
}

resource "null_resource" "setup_kubectl" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "bash -c 'aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name}'"
  }
  depends_on = [aws_eks_cluster.default]
}

resource "null_resource" "setup_calico" {
  provisioner "local-exec" {
    command = "timeout 60 bash -c 'until kubectl apply -f ${path.module}/files/calico-1.5.yml;do sleep 5; done'"
  }
  depends_on = [null_resource.setup_kubectl]
}

resource "null_resource" "populate_auth_map" {
  provisioner "local-exec" {
    command = "timeout 60 bash -c 'until kubectl apply -f ${local_file.aws_auth_cm.filename};do sleep 5; done'"
  }
  depends_on = [null_resource.setup_kubectl]
}

resource "null_resource" "setup_cluster_autoscaler" {
  provisioner "local-exec" {
    command = "timeout 60 bash -c 'until kubectl apply -f ${local_file.cluster_autoscaler.filename};do sleep 5; done'"
  }
  depends_on = [null_resource.setup_calico]
}

resource "aws_launch_configuration" "main" {
  associate_public_ip_address = false
  iam_instance_profile        = var.node_instance_profile_name
  image_id                    = var.node_ami
  instance_type               = var.node_machine_type
  name                        = "tf-${var.cluster_name}-node"
  security_groups             = [var.node_sg_id]
  key_name                    = var.cluster_name
  user_data_base64            = base64encode(templatefile("${path.module}/templates/node.tpl", {
                                             endpoint              = aws_eks_cluster.default.endpoint,
                                             certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                                             name                  = var.cluster_name,
                                             taints                = "",
                                             labels                = "" }))
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.main.id
  max_size             = var.num_nodes_max
  min_size             = var.num_nodes_min
  name                 = "tf-${var.cluster_name}-node"
  vpc_zone_identifier  = var.subnet_ids

  tag {
    key                 = "Name"
    value               = "tf-${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = aws_eks_cluster.default.name
    propagate_at_launch = false
  }

  depends_on = [null_resource.populate_auth_map]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Training node pool
resource "aws_launch_configuration" "training" {
  associate_public_ip_address = false
  iam_instance_profile        = var.node_instance_profile_name
  image_id                    = var.node_ami
  instance_type               = var.node_machine_type_highcpu
  name                        = "tf-${var.cluster_name}-training"
  security_groups             = [var.node_sg_id]
  user_data_base64            = base64encode(templatefile("${path.module}/templates/node.tpl", {
                                             endpoint              = aws_eks_cluster.default.endpoint,
                                             certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                                             name                  = var.cluster_name,
                                             taints                = "dedicated=training:NoSchedule",
                                             labels                = "mode=legion-training" }))

  key_name                    = var.cluster_name

  root_block_device {
    volume_type           = "standard"
    volume_size           = "50"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "training" {
  desired_capacity     = 0
  launch_configuration = aws_launch_configuration.training.id
  max_size             = var.num_nodes_highcpu_max
  min_size             = 0
  name                 = "tf-${var.cluster_name}-training"
  vpc_zone_identifier  = var.subnet_ids

  tag {
    key                 = "Name"
    value               = "tf-${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = aws_eks_cluster.default.name
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/mode"
    value               = "legion-training"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/taint/dedicated"
    value               = "training:NO_SCHEDULE"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Packaging node pool
resource "aws_launch_configuration" "packaging" {
  associate_public_ip_address = false
  iam_instance_profile        = var.node_instance_profile_name
  image_id                    = var.node_ami
  instance_type               = var.node_machine_type_highcpu
  name                        = "tf-${var.cluster_name}-packaging"
  security_groups             = [var.node_sg_id]
  user_data_base64            = base64encode(templatefile("${path.module}/templates/node.tpl", {
                                             endpoint              = aws_eks_cluster.default.endpoint,
                                             certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                                             name                  = var.cluster_name,
                                             taints                = "dedicated=packaging:NoSchedule",
                                             labels                = "mode=legion-packaging" }))

  key_name                    = var.cluster_name

  root_block_device {
    volume_type           = "standard"
    volume_size           = "100"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "packaging" {
  desired_capacity     = 0
  launch_configuration = aws_launch_configuration.packaging.id
  max_size             = var.num_nodes_highcpu_max
  min_size             = 0
  name                 = "tf-${var.cluster_name}-packaging"
  vpc_zone_identifier  = var.subnet_ids

  tag {
    key                 = "Name"
    value               = "tf-${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = aws_eks_cluster.default.name
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/mode"
    value               = "legion-packaging"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/taint/dedicated"
    value               = "packaging:NO_SCHEDULE"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

#  Deployment node pool
resource "aws_launch_configuration" "deployment" {
  associate_public_ip_address = false
  iam_instance_profile        = var.node_instance_profile_name
  image_id                    = var.node_ami
  instance_type               = var.node_machine_type_highcpu
  name                        = "tf-${var.cluster_name}-deployment"
  security_groups             = [var.node_sg_id]
  user_data_base64            = base64encode(templatefile("${path.module}/templates/node.tpl", {
                                             endpoint              = aws_eks_cluster.default.endpoint,
                                             certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                                             name                  = var.cluster_name,
                                             taints                = "dedicated=deployment:NoSchedule",
                                             labels                = "mode=legion-deployment" }))

  key_name                    = var.cluster_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "deployment" {
  desired_capacity     = 0
  launch_configuration = aws_launch_configuration.deployment.id
  max_size             = var.num_nodes_highcpu_max
  min_size             = 0
  name                 = "tf-${var.cluster_name}-deployment"
  vpc_zone_identifier  = var.subnet_ids

  tag {
    key                 = "Name"
    value               = "tf-${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = aws_eks_cluster.default.name
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/mode"
    value               = "legion-deployment"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/taint/dedicated"
    value               = "deployment:NO_SCHEDULE"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

########################################################
#  DNS records
########################################################

# Wait for cluster startup
resource "null_resource" "kubectl_config" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "timeout 1200 bash -c 'until curl -sk ${aws_eks_cluster.default.endpoint}; do sleep 20; done'"
  }

  depends_on = [aws_eks_cluster.default]
}
