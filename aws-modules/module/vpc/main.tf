#############
# Basic VPC
#############

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_range
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.default_tenancy

#  tags = merge
#     local.tags,
#     local.single_nat_tag[var.single_nat],
#     {
#       Name = var.name
#     },
#   )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  count = var.enable_dhcp_options ? 1 : 0
  domain_name         = var.domain_name
  domain_name_servers = var.domain_name_servers

#   tags = merge(
#     local.tags,
#     {
#       Name = "${var.name}-DHCPOptions"
#     },
#   )
}

resource "aws_internet_gateway" "igw" {
  count = var.build_igw ? 1 : 0

  vpc_id = aws_vpc.vpc.id

#   tags = merge(
#     local.tags,
#     {
#       Name = format("%s-IGW", var.name)
#     },
#   )
}

#############
# NAT Gateway
#############

resource "aws_eip" "nat_eip" {
  count = var.number_of_ngw
  vpc = true
  # tags = merge(
  #   local.tags,
  #   {
  #     Name = format("%s-NATEIP%d", var.name, count.index + 1)
  #   },
  # )
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count = var.number_of_ngw
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on = [aws_internet_gateway.igw]
}

#############
# Subnets
#############

resource "aws_subnet" "public_subnet" {
  count                  = length(var.public_cidr_ranges)
  availability_zone       = element(var.azs, count.index)
  cidr_block              = var.public_cidr_ranges[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id
}

resource "aws_subnet" "private_subnet" {
  count                  = length(var.private_cidr_ranges)
  availability_zone       = element(var.azs, count.index)
  cidr_block              = var.private_cidr_ranges[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id
}

#########################
# Route Tables and Routes
#########################

resource "aws_route_table" "public_route_table" {
  count = var.build_igw ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  # tags = merge(
  #   local.tags,
  #   {
  #     Name = format("%s-PublicRouteTable", var.name)
  #   },
  # )
}

resource "aws_route_table" "private_route_table" {
  count = var.az_count

  vpc_id = aws_vpc.vpc.id

  # tags = merge(
  #   local.tags,
  #   local.single_nat_tag[var.single_nat],
  #   {
  #     Name = format("%s-PrivateRouteTable%d", var.name, count.index + 1)
  #   },
  # )
}

resource "aws_route" "public_routes" {
  count = var.build_igw ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  route_table_id         = aws_route_table.public_route_table[0].id
}

resource "aws_route" "private_routes" {
  count = var.build_nat_gateways && var.build_igw ? var.az_count : 0

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
  route_table_id         = element(aws_route_table.private_route_table.*.id, count.index)
}