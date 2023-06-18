output "elb_id" {
  description = "The name of the ELB"
  value       = aws_elb.this.id
}

output "elb_arn" {
  description = "The ARN of the ELB"
  value       = aws_elb.this.arn
}

output "elb_name" {
  description = "The name of the ELB"
  value       = aws_elb.this.name
}

output "elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = try(aws_route53_record.load_balancer_endpoint[0].name, "")
}

output "elb_instances" {
  description = "The list of instances in the ELB"
  value       = flatten(aws_elb.this.instances)
}
