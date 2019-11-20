# Create VPC
resource "aws_vpc" "default" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = var.cluster_name,
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  }
}

resource "aws_subnet" "nat" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.nat_subnet_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.az_list, 0)

  tags = {
    Name = "tf-${var.cluster_name}-nat"
  }
}

resource "aws_route" "nat" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public" {
  count                   = length(var.az_list)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.az_list, count.index)

  tags = {
    Name = "tf-${var.cluster_name}-public"
    Tier = "Public"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.az_list)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.az_list, count.index)

  tags = {
    Name                                        = "tf-${var.cluster_name}-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Tier                                        = "Private"
  }
}

data "aws_eip" "nat" {
  filter {
    name   = "tag:Name"
    values = [var.cluster_name]
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = var.cluster_name
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default.id
  }

  tags = {
    Name = "tf-${var.cluster_name}"
  }
}

resource "aws_route_table_association" "default" {
  count          = length(var.az_list)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.default.id
}

resource "aws_nat_gateway" "default" {
  subnet_id     = aws_subnet.nat.id
  allocation_id = data.aws_eip.nat.id
  depends_on    = [aws_internet_gateway.default]
}
