# vpc
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-${var.env}"
    Project = var.project
    Env     = var.env
  }
}

# internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.project}-${var.env}"
    Project = var.project
    Env     = var.env
  }
}

# eip
resource "aws_eip" "this" {
  count = length(var.cidr_pri)
  vpc   = true

  tags = {
    Name    = "${var.project}-${var.env}-${element(local.aws_availability_zones, count.index)}"
    Project = var.project
    Env     = var.env
  }
}

# subnets
resource "aws_subnet" "private" {
  count                   = length(var.cidr_pri)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.cidr_pri, count.index)
  availability_zone       = element(local.aws_availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.env}-private-${element(local.aws_availability_zones, count.index)}"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.cidr_pub)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.cidr_pub, count.index)
  availability_zone       = element(local.aws_availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.env}-public-${element(local.aws_availability_zones, count.index)}"
    Project = var.project
    Env     = var.env
  }
}

# nat gateway
resource "aws_nat_gateway" "this" {
  count         = length(var.cidr_pri)
  allocation_id = element(aws_eip.this.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name    = "${var.project}-${var.env}-${element(local.aws_availability_zones, count.index)}"
    Project = var.project
    Env     = var.env
  }
}

# route table private
resource "aws_route_table" "private" {
  count  = length(var.cidr_pri)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.this.*.id, count.index)
  }

  tags = {
    Name    = "${var.project}-${var.env}-private-${element(local.aws_availability_zones, count.index)}"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.cidr_pri)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# route table public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name    = "${var.project}-${var.env}-public"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.cidr_pub)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

