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

resource "aws_launch_template" "main" {
  name           = "tf-${var.cluster_name}-node"
  image_id       = var.node_ami
  instance_type  = var.node_machine_type
  key_name       = var.cluster_name
  user_data      = base64encode(templatefile("${path.module}/templates/node.tpl", {
                                    endpoint              = aws_eks_cluster.default.endpoint,
                                    certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                                    name                  = var.cluster_name,
                                    taints                = "",
                                    labels                = "" }))
  iam_instance_profile {
    name = var.node_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = ["${var.node_sg_id}"]
    delete_on_termination       = true
  }

  instance_initiated_shutdown_behavior = "terminate"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity     = 1
  max_size             = var.num_nodes_max
  min_size             = var.num_nodes_min
  name                 = "tf-${var.cluster_name}-node"

  launch_template {
    id      = "${aws_launch_template.main.id}"
    version = "$Latest"
  }

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
resource "aws_launch_template" "training" {
  name           = "tf-${var.cluster_name}-training"
  image_id       = var.node_ami
  instance_type  = var.node_machine_type
  key_name       = var.cluster_name

  user_data = base64encode(templatefile("${path.module}/templates/node.tpl", {
                               endpoint              = aws_eks_cluster.default.endpoint,
                               certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                               name                  = var.cluster_name,
                               taints                = "dedicated=training:NoSchedule",
                               labels                = "mode=legion-training" }))


  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "standard"
      volume_size           = "50"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = var.node_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = ["${var.node_sg_id}"]
    delete_on_termination       = true
  }

  instance_initiated_shutdown_behavior = "terminate"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "training" {
  desired_capacity     = 0
  max_size             = var.num_nodes_highcpu_max
  min_size             = 0
  name                 = "tf-${var.cluster_name}-training"
  vpc_zone_identifier  = var.subnet_ids

  launch_template {
    id      = "${aws_launch_template.training.id}"
    version = "$Latest"
  }

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
resource "aws_launch_template" "packaging" {
  name          = "tf-${var.cluster_name}-packaging"
  image_id      = var.node_ami
  instance_type = var.node_machine_type_highcpu
  key_name      = var.cluster_name
  user_data     = base64encode(templatefile("${path.module}/templates/node.tpl", {
                                   endpoint              = aws_eks_cluster.default.endpoint,
                                   certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                                   name                  = var.cluster_name,
                                   taints                = "dedicated=packaging:NoSchedule",
                                   labels                = "mode=legion-packaging" }))

  iam_instance_profile {
    name = var.node_instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "standard"
      volume_size           = "100"
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = ["${var.node_sg_id}"]
    delete_on_termination       = true
  }

  instance_initiated_shutdown_behavior = "terminate"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "packaging" {
  desired_capacity     = 0
  max_size             = var.num_nodes_highcpu_max
  min_size             = 0
  name                 = "tf-${var.cluster_name}-packaging"
  vpc_zone_identifier  = var.subnet_ids

  launch_template {
    id      = "${aws_launch_template.packaging.id}"
    version = "$Latest"
  }

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
resource "aws_launch_template" "deployment" {
  name          = "tf-${var.cluster_name}-deployment"
  image_id      = var.node_ami
  instance_type = var.node_machine_type_highcpu
  key_name      = var.cluster_name
  user_data     = base64encode(templatefile("${path.module}/templates/node.tpl", {
                                   endpoint              = aws_eks_cluster.default.endpoint,
                                   certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
                                   name                  = var.cluster_name,
                                   taints                = "dedicated=deployment:NoSchedule",
                                   labels                = "mode=legion-deployment" }))

  iam_instance_profile {
    name = var.node_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = ["${var.node_sg_id}"]
    delete_on_termination       = true
  }

  instance_initiated_shutdown_behavior = "terminate"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "deployment" {
  desired_capacity     = 0
  max_size             = var.num_nodes_highcpu_max
  min_size             = 0
  name                 = "tf-${var.cluster_name}-deployment"
  vpc_zone_identifier  = var.subnet_ids

  launch_template {
    id      = "${aws_launch_template.deployment.id}"
    version = "$Latest"
  }

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
