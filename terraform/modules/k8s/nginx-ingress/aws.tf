locals {
  aws_resouce_count = var.cluster_type == "aws/eks" ? 1 : 0
}

# Data
data "aws_vpc" "default" {
  count  = local.aws_resouce_count
  filter {
    name   = "tag:Name"
    values = [var.cluster_name]
  }
}

data "aws_subnet_ids" "public" {
  count  = local.aws_resouce_count
  vpc_id = data.aws_vpc.default[0].id
  tags = {
    Tier = "Public"
  }
}
data "aws_security_group" "lb" {
  count  = local.aws_resouce_count
  vpc_id = data.aws_vpc.default[0].id
  name   = "tf-${var.cluster_name}-lb"
}

data "aws_autoscaling_groups" "default" {
}

# ELB
resource "aws_elb" "default" {
  count           = local.aws_resouce_count
  name            = var.cluster_name
  internal        = false
  subnets         = data.aws_subnet_ids.public[0].ids
  security_groups = [data.aws_security_group.lb[0].id]
  listener {
    instance_port     = 30000
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 30001
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }
  cross_zone_load_balancing = false

  tags = {
    Name = "tf-${var.cluster_name}-elb"
  }
}

resource "aws_autoscaling_attachment" "default" {
  count                  = local.aws_resouce_count == 0 ? 0 : length(data.aws_autoscaling_groups.default.names)
  autoscaling_group_name = element(data.aws_autoscaling_groups.default.names, count.index)
  elb                    = aws_elb.default[0].id
}

# ToDo: remove Google Cloud DNS resources from AWS EKS cluster setup
resource "google_dns_record_set" "aws_ingress_lb" {
  count        = local.aws_resouce_count
  name         = "*.${var.cluster_name}.${var.root_domain}."
  managed_zone = var.dns_zone_name
  project      = var.project_id
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${aws_elb.default[0].dns_name}."]
}
