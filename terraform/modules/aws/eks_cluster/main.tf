resource "local_file" "aws_auth_cm" {
  content = templatefile("${path.module}/templates/aws-auth-cm.tpl", {
    node_role_arn = var.node_role_arn
  })
  filename = "/tmp/.odahu/aws_auth_cm.yml"

  file_permission      = 0644
  directory_permission = 0755
}

########################################################
# Bastion
########################################################
resource "aws_instance" "bastion" {
  count                       = var.bastion_enabled ? 1 : 0
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
  name     = var.cluster_name
  role_arn = var.master_role_arn
  version  = var.k8s_version

  vpc_config {
    security_group_ids = [var.master_sg_id]
    subnet_ids         = var.subnet_ids
  }
  depends_on = [null_resource.aws_eni_cleanup]
}

resource "null_resource" "aws_eni_cleanup" {
  triggers = {
    cluster_name = var.cluster_name
    aws_region   = var.aws_region
  }
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "bash ../../../../../scripts/aws_eni_cleanup.sh \"${self.triggers.cluster_name}\" \"${self.triggers.aws_region}\""
  }
}

resource "null_resource" "kube_api_check" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "timeout 1200 bash -c 'until curl -sk ${aws_eks_cluster.default.endpoint}; do sleep 20; done'"
  }

  depends_on = [aws_eks_cluster.default]
}

resource "null_resource" "setup_kubectl" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "bash -c 'aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name}'"
  }
  depends_on = [
    aws_eks_cluster.default,
    null_resource.kube_api_check
  ]
}

resource "null_resource" "populate_auth_map" {
  provisioner "local-exec" {
    command = "timeout 90 bash -c 'until kubectl apply -f ${local_file.aws_auth_cm.filename}; do sleep 5; done'"
  }
  depends_on = [
    null_resource.setup_kubectl,
    local_file.aws_auth_cm
  ]
}

resource "null_resource" "setup_calico" {
  provisioner "local-exec" {
    command = "timeout 90 bash -c 'until kubectl apply -f ${path.module}/files/calico-1.5.yml; do sleep 5; done'"
  }
  depends_on = [
    null_resource.setup_kubectl,
    null_resource.populate_auth_map
  ]
}

# Node pools
resource "aws_launch_template" "this" {
  for_each      = var.node_pools
  name          = "tf-${var.cluster_name}-${substr(replace(each.key, "/[_\\W]/", "-"), 0, 40)}"
  image_id      = lookup(each.value, "image", var.node_ami)
  instance_type = lookup(each.value, "machine_type", "m5.large")
  key_name      = var.cluster_name

  user_data = base64encode(templatefile("${path.module}/templates/node.tpl", {
    endpoint              = aws_eks_cluster.default.endpoint,
    certificate_authority = aws_eks_cluster.default.certificate_authority.0.data,
    name                  = var.cluster_name,
    taints                = join(",", [for t in lookup(each.value, "taints", []) : "${t.key}=${t.value}:${replace(title(lower(replace(t.effect, "_", " "))), " ", "")}"]),
    labels                = join(",", concat([for k in keys(lookup(each.value, "labels", {})) : "${k}=${lookup(each.value, "labels")[k]}"], ["project=odahu-flow"]))
  }))

  dynamic "instance_market_options" {
    for_each = [for i in [lookup(each.value, "preemptible", "false")] : i if i != "false"]
    content {
      market_type = "spot"
      spot_options {
        block_duration_minutes         = 60
        spot_instance_type             = "one-time"
        instance_interruption_behavior = "terminate"
      }
    }
  }

  dynamic "block_device_mappings" {
    for_each = flatten([lookup(each.value, "disk_size_gb", "40")])
    iterator = size
    content {
      device_name = "/dev/xvda"
      ebs {
        kms_key_id            = var.kms_key_arn
        encrypted             = var.kms_key_arn == "" ? false : true
        volume_type           = lookup(each.value, "disk_type", "standard")
        volume_size           = size.value
        delete_on_termination = true
      }
    }
  }

  iam_instance_profile {
    name = var.node_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.node_sg_id]
    delete_on_termination       = true
  }

  instance_initiated_shutdown_behavior = "terminate"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  for_each = var.node_pools

  desired_capacity        = lookup(each.value, "init_node_count", 0)
  min_size                = lookup(each.value, "min_node_count", "0")
  max_size                = lookup(each.value, "max_node_count", "2")
  name                    = "tf-${var.cluster_name}-${substr(replace(each.key, "/[_\\W]/", "-"), 0, 40)}"
  vpc_zone_identifier     = var.subnet_ids
  service_linked_role_arn = var.service_linked_role_arn

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = substr(replace(each.key, "/[_\\W]/", "-"), 0, 40)
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

  dynamic "tag" {
    for_each = lookup(each.value, "labels", {})
    iterator = tag
    content {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/${tag.key}"
      value               = tag.value
      propagate_at_launch = false
    }
  }

  dynamic "tag" {
    for_each = lookup(each.value, "taints", [])
    iterator = taint
    content {
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/${taint.value.key}"
      value               = "${taint.value.value}:${taint.value.effect}"
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}
