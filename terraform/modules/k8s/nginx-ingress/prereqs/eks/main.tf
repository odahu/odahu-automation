# Data
data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = [var.cluster_name]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    Tier = "Public"
  }
}
data "aws_security_group" "lb" {
  vpc_id = data.aws_vpc.default.id
  name   = "tf-${var.cluster_name}-lb"
}

data "aws_autoscaling_groups" "default" {
  filter {
    name   = "auto-scaling-group"
    values = ["tf-${var.cluster_name}-node"]
  }
}

# ELB
resource "aws_elb" "default" {
  name            = var.cluster_name
  internal        = false
  subnets         = data.aws_subnet_ids.public.ids
  security_groups = [data.aws_security_group.lb.id]
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
  count                  = length(data.aws_autoscaling_groups.default.names)
  autoscaling_group_name = element(data.aws_autoscaling_groups.default.names, count.index)
  elb                    = aws_elb.default.id
}
