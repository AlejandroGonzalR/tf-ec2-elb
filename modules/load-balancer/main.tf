resource "aws_elb" "this" {
  name        = var.name
  name_prefix = var.name_prefix

  subnets         = var.subnets
  internal        = var.internal
  security_groups = var.security_groups

  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout

  dynamic "listener" {
    for_each = var.listeners

    content {
      instance_port      = listener.value.instance_port
      instance_protocol  = listener.value.instance_protocol
      lb_port            = listener.value.lb_port
      lb_protocol        = listener.value.lb_protocol
      ssl_certificate_id = lookup(listener.value, "ssl_certificate_id", null)
    }
  }

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []

    content {
      enabled       = coalesce(access_logs.value.enabled, access_logs.value.bucket != null)
      bucket        = access_logs.value.bucket
      bucket_prefix = access_logs.value.prefix
    }
  }

  health_check {
    healthy_threshold   = lookup(var.health_check, "healthy_threshold")
    unhealthy_threshold = lookup(var.health_check, "unhealthy_threshold")
    target              = lookup(var.health_check, "target")
    interval            = lookup(var.health_check, "interval")
    timeout             = lookup(var.health_check, "timeout")
  }

  tags = merge(
    var.global_tags,
    {
      Name = var.name
    },
  )
}

resource "aws_elb_attachment" "this" {
  count = length(var.instances)

  elb      = aws_elb.this
  instance = element(var.instances, count.index)
}

#########################################################
# Custom Load Balancer endpoint configuration
#########################################################

module "alb_ssl_cert" {
  count = var.domain_name != null ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.elb_root_domain[0].zone_id

  subject_alternative_names = ["*.${var.domain_name}"]

  tags = merge(
    var.global_tags,
    {
      Name = var.domain_name
    }
  )
}

resource "aws_route53_record" "load_balancer_endpoint" {
  count = var.domain_name != null ? 1 : 0

  zone_id = data.aws_route53_zone.elb_root_domain[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_elb.this.dns_name
    zone_id                = aws_elb.this.zone_id
    evaluate_target_health = true
  }
}
