#############
# Basic VPC
#############

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_range
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.default_tenancy

 tags = merge(
    local.base_tags,{
    Name = "${var.env_naming}_${var.application}_vpc"
    }
  )
    
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  count = var.enable_dhcp_options ? 1 : 0
  domain_name         = var.domain_name
  domain_name_servers = var.domain_name_servers

  tags = merge(
    local.base_tags,
    {
      Name = "${var.env_naming}_${var.application}_DHCPOptions"
    },
  )
}

resource "aws_internet_gateway" "igw" {
  count = var.build_igw ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.base_tags,
    {
      Name = "${var.env_naming}_${var.application}_igw"
    },
  )
}

#############
# NAT Gateway
#############

resource "aws_eip" "nat_eip" {
  count = var.number_of_ngw
  vpc = true
  tags = merge(
    local.base_tags,
    {
      Name = "${var.env_naming}_${var.application}_eip_${count.index + 1}"
    },
  )
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count = var.number_of_ngw
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on = [aws_internet_gateway.igw]
  tags = merge(
    local.base_tags,
    {
      Name = "${var.env_naming}_${var.application}_nat_${count.index + 1}"
    },
  )
}

#############
# Subnets
#############

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_cidr_ranges)
  availability_zone       = element(var.azs, count.index)
  cidr_block              = var.public_cidr_ranges[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id

  tags = merge(
    local.base_tags,
    {
      Name = "${var.env_naming}_${var.application}_vpc_${var.primary_subnet_type}_${local.subnet_tag[count.index]}_sn"
    },
  )  
}

resource "aws_subnet" "private_subnet" {
  count                  = length(var.private_cidr_ranges)
  availability_zone       = element(var.azs, count.index)
  cidr_block              = var.private_cidr_ranges[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id

   tags = merge(
    local.base_tags,
    {
        Name = "${var.env_naming}_${var.application}_vpc_${var.secondary_subnet_type}_${local.subnet_tag[count.index]}_sn"
    },
  )
}

#########################
# Route Tables and Routes
#########################

resource "aws_route_table" "public_route_table" {
  count = var.build_igw ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.base_tags,
    {
      Name = "${var.env_naming}_${var.application}_${var.primary_subnet_type}_${local.subnet_tag[count.index]}_routetable"
    },
  )
}

resource "aws_route_table" "private_route_table" {
  count = var.az_count

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.base_tags,
    {
      Name = "${var.env_naming}_${var.application}_${var.secondary_subnet_type}_${local.subnet_tag[count.index]}_routetable"
    },
  )
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

resource "aws_route_table_association" "public_route_association" {
  count = var.build_igw ? var.az_count * var.public_subnets_per_az : 0

  route_table_id = aws_route_table.public_route_table[0].id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}

resource "aws_route_table_association" "private_route_association" {
  count = var.az_count * var.private_subnets_per_az

  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
}

###########
# Flow Logs
###########

resource "aws_flow_log" "s3_vpc_log" {
  count = var.build_s3_flow_logs ? 1 : 0

  log_destination      = aws_s3_bucket.vpc_log_bucket[0].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
}

resource "aws_s3_bucket" "vpc_log_bucket" {
  count = var.build_s3_flow_logs ? 1 : 0

  bucket        = "${var.env_naming}-${var.application}-s3-flowlogs-${substr(sha256(var.application),0 ,12)}"
  force_destroy = var.logging_bucket_force_destroy
  tags = merge(
    local.base_tags,
    {
      Name  = "${var.env_naming}-${var.application}-s3-flowlogs-${substr(sha256(var.application),0 ,12)}"
    },
  )
  
}

resource "aws_s3_bucket_acl" "private_acl" {
  count = var.build_s3_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.vpc_log_bucket[count.index].id
  acl    = var.logging_bucket_access_control
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  count = var.build_s3_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.vpc_log_bucket[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.logging_bucket_encryption_kms_mster_key
      sse_algorithm     = var.logging_bucket_encryption
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  count = var.build_s3_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.vpc_log_bucket[count.index].id
  rule {
    id     = "Expiration"
    status = "Enabled"
    filter {
    prefix = var.logging_bucket_prefix
    }
    expiration {
      days = var.s3_flowlog_retention
    }
  }
}

resource "aws_flow_log" "cw_vpc_log" {
  count = var.build_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flowlog_role[0].arn
  log_destination = aws_cloudwatch_log_group.flowlog_group[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "flowlog_group" {
  count = var.build_flow_logs ? 1 : 0

  name              = "${var.env_naming}_${var.application}_cw_flowlogs_group"
  retention_in_days = var.cloudwatch_flowlog_retention
  tags = merge(
    local.base_tags,
    {
        Name  = "${var.env_naming}_${var.application}_cw_flowlogs_group"
    },
  )

}

resource "aws_iam_role" "flowlog_role" {
  count = var.build_flow_logs ? 1 : 0

  name  = "${var.env_naming}_${var.application}_flowlogs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
tags = merge(
    local.base_tags,
    {
        Name = "${var.env_naming}_${var.application}_flowlogs_role"
    }
)
}


resource "aws_iam_role_policy" "flowlog_policy" {
  count = var.build_flow_logs ? 1 : 0

  name  = "${var.env_naming}_${var.application}_flowlogs_policy"
  role = aws_iam_role.flowlog_role[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "${replace(aws_cloudwatch_log_group.flowlog_group[0].arn, ":*", "")}:*"
    }
  ]
}
EOF
}
