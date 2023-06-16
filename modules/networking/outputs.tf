output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "vpc_default_route_table_id" {
  value = aws_vpc.this.default_route_table_id
}

output "subnet_ids" {
  value = tomap({
    for name, subnet in aws_subnet.subnet : name => subnet.id
  })
}

output "security_groups_ids" {
  value = tomap({
    for name, security_group in aws_security_group.security_group : name => security_group.id
  })
}
