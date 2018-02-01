locals {
  az_count        = "${length(var.azs)}"
  subnet_count    = "${local.az_count * 2}"
  subnet_maskbits = "${ceil(log(local.subnet_count, 2))}"
}


#------
# VPC
#------

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  instance_tenancy     = "${var.instance_tenancy}"

  tags {
    Name = "${var.name_prefix}-vpc"
  }
}


#-------
# IGW
#-------

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name_prefix}-igw"
  }
}


#-----------------
# Public subnets
#-----------------

resource "aws_subnet" "public_subnet" {
  count                   = "${local.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${var.azs[count.index]}"
  # workaround described in https://github.com/hashicorp/terraform/issues/11210 is used in cidr_block attribute interpolation
  cidr_block              = "${length(var.public_subnet_cidrs) > 0 ? element(concat(var.public_subnet_cidrs, list("")), count.index) : cidrsubnet(var.cidr, local.subnet_maskbits, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name_prefix}-public-subnet-${var.azs[count.index]}"
  }
}


#------------------
# Private subnets
#------------------

resource "aws_subnet" "private_subnet" {
  count                   = "${local.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${var.azs[count.index]}"
  # workaround described in https://github.com/hashicorp/terraform/issues/11210 is used in cidr_block attribute interpolation
  cidr_block              = "${length(var.private_subnet_cidrs) > 0 ? element(concat(var.private_subnet_cidrs, list("")), count.index) : cidrsubnet(var.cidr, local.subnet_maskbits, count.index + local.az_count)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.name_prefix}-private-subnet-${var.azs[count.index]}"
  }
}


#----------------------------------
# Route tables for public subnets
#----------------------------------

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_associations" {
  count          = "${aws_subnet.public_subnet.count}"
  route_table_id = "${aws_route_table.public_route_table.id}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
}

#---------------
# NAT gateways
#---------------

locals {
  nat_gateway_count = "${var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.az_count) : 0}"
}

resource "aws_eip" "nat_eip" {
  count      = "${local.nat_gateway_count}"
  vpc        = true
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = "${local.nat_gateway_count}"
  allocation_id = "${aws_eip.nat_eip.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public_subnet.*.id[count.index]}"
  depends_on    = ["aws_internet_gateway.igw"]
}


#-----------------------------------
# Route tables for private subnets
#-----------------------------------

locals {
  private_route_table_count = "${max(1, local.nat_gateway_count)}"
}

resource "aws_route_table" "private_route_table" {
  count  = "${local.private_route_table_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${format("%s-private-route-table%s", var.name_prefix, local.private_route_table_count == 1 ? "" : "-${var.azs[count.index]}")}"
  }
}

resource "aws_route" "nat_gateway_route" {
  count                  = "${local.nat_gateway_count}"
  route_table_id         = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
}

resource "aws_route_table_association" "private_route_table_associations" {
  count          = "${aws_subnet.private_subnet.count}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
}


#------------------
# S3 VPC Endpoint
#------------------

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  count        = "${var.enable_s3_endpoint ? 1 : 0}"
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "public_subnet_s3_route" {
  count           = "${var.enable_s3_endpoint ? 1 : 0}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3_vpc_endpoint.id}"
  route_table_id  = "${aws_route_table.public_route_table.id}"
}

resource "aws_vpc_endpoint_route_table_association" "private_subnet_s3_route" {
  count           = "${var.enable_s3_endpoint ? aws_route_table.private_route_table.count : 0}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3_vpc_endpoint.id}"
  route_table_id  = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}

#------------------------
# DynamoDB VPC Endpoint
#------------------------

data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb_vpc_endpoint" {
  count        = "${var.enable_dynamodb_endpoint ? 1 : 0}"
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "public_subnet_dynamodb_route" {
  count           = "${var.enable_dynamodb_endpoint ? 1 : 0}"
  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb_vpc_endpoint.id}"
  route_table_id  = "${aws_route_table.public_route_table.id}"
}

resource "aws_vpc_endpoint_route_table_association" "private_subnet_dynamodb_route" {
  count           = "${var.enable_dynamodb_endpoint ? aws_route_table.private_route_table.count : 0}"
  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb_vpc_endpoint.id}"
  route_table_id  = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}