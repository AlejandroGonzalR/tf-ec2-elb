locals {
  # This is the default format for dynamic resources naming in case the name is not specified.
  # The format is expected to use the environment name and a sequential index.
  default_identification_format = "%s-%d"

  subnets = {
    for idx, subnet in var.subnets :
    lookup(subnet, "name", format(local.default_identification_format, lower(var.workspace_name), idx)) => subnet
  }

  security_groups = {
    for idx, security_group in var.security_groups :
    lookup(security_group, "name", format(local.default_identification_format, lower(var.workspace_name), idx)) => security_group
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.global_tags,
    {
      Name = var.workspace_name
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.global_tags,
    {
      Name = var.workspace_name
    }
  )
}

resource "aws_route" "api_services_internet_gateway_route" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_subnet" "subnet" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value["cidr_block"]
  availability_zone       = each.value["availability_zone"]
  map_public_ip_on_launch = each.value["map_public_ip_on_launch"]

  tags = merge(
    var.global_tags,
    {
      Name = "${each.key} - var.workspace_name - AZ ${each.value["availability_zone"]}"
    }
  )
}

resource "aws_security_group" "security_group" {
  for_each = local.security_groups

  name        = "${each.key}_${var.workspace_name}"
  description = each.value["description"]
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = each.value["ingress"] != null ? each.value["ingress"] : []

    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  dynamic "egress" {
    for_each = each.value["egress"] != null ? each.value["egress"] : []

    content {
      description = egress.value["description"]
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      protocol    = egress.value["protocol"]
      cidr_blocks = egress.value["cidr_blocks"]
    }
  }

  tags = merge(
    var.global_tags,
    {
      Name = "${title(replace(each.key, "-", " "))} - ${var.workspace_name}"
    }
  )
}
