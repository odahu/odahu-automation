locals {
  vpc                = length(var.vpc_name) == 0 ? aws_vpc.default[0] : data.aws_vpc.default[0]
  aws_route_table_id = length(var.vpc_name) == 0 ? aws_route_table.default[0].id : ""
  public_subnet_ids  = length(var.public_subnet_ids) == 0 ? aws_subnet.public.*.id : data.aws_subnet_ids.public[0].ids
  private_subnet_ids = length(var.private_subnet_ids) == 0 ? aws_subnet.private.*.id : data.aws_subnet_ids.private[0].ids
}

# Create VPC
resource "aws_vpc" "default" {
  count                = length(var.vpc_name) == 0 ? 1 : 0
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = var.cluster_name,
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash ../../../../../scripts/aws_sg_cleanup.sh \"${var.cluster_name}\" \"${var.aws_region}\""
  }
}

data "aws_vpc" "default" {
  count = length(var.vpc_name) == 0 ? 0 : 1

  filter {
    name   = "tag:Name"
    values = [var.cluster_name]
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_ids) == 0 ? length(var.az_list) : 0

  vpc_id                  = local.vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.az_list, count.index)

  tags = {
    Name = "tf-${var.cluster_name}-public"
    Tier = "Public"
  }
}

data "aws_subnet_ids" "public" {
  count = length(var.public_subnet_ids) == 0 ? 0 : 1

  vpc_id = local.vpc.id

  filter {
    name   = "subnet-id"
    values = var.public_subnet_ids
  }
}

# Create public subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_ids) == 0 ? length(var.az_list) : 0

  vpc_id                  = aws_vpc.default[0].id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.az_list, count.index)

  tags = {
    Name                                        = "tf-${var.cluster_name}-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Tier                                        = "Private"
  }
}

data "aws_subnet_ids" "private" {
  count = length(var.private_subnet_ids) == 0 ? 0 : 1

  vpc_id = local.vpc.id

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }
}

data "aws_eip" "nat" {
  count = length(var.vpc_name) == 0 ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.cluster_name]
  }
}

resource "aws_subnet" "nat" {
  count = length(var.vpc_name) == 0 ? 1 : 0

  vpc_id                  = local.vpc.id
  cidr_block              = var.nat_subnet_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.az_list, 0)

  tags = {
    Name = "tf-${var.cluster_name}-nat"
  }
}

resource "aws_route" "nat" {
  count = length(var.vpc_name) == 0 ? 1 : 0

  route_table_id         = aws_vpc.default[0].main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default[0].id
}

resource "aws_internet_gateway" "default" {
  count = length(var.vpc_name) == 0 ? 1 : 0

  vpc_id = aws_vpc.default[0].id

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_nat_gateway" "default" {
  count = length(var.vpc_name) == 0 ? 1 : 0

  subnet_id     = aws_subnet.nat[0].id
  allocation_id = data.aws_eip.nat[0].id
  depends_on    = [aws_internet_gateway.default[0]]
}

resource "aws_route_table" "default" {
  count = length(var.vpc_name) == 0 ? 1 : 0

  vpc_id = aws_vpc.default[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default[0].id
  }

  tags = {
    Name = "tf-${var.cluster_name}"
  }
}

resource "aws_route_table_association" "default" {
  count          = length(var.vpc_name) == 0 ? length(var.az_list) : 0
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.default[0].id
}
