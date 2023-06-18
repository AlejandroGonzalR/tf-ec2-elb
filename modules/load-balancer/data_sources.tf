data "aws_route53_zone" "elb_root_domain" {
  count = var.domain_name != null ? 1 : 0

  name = var.elb_root_domain
}
