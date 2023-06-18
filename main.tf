locals {
  global_tags = {
    Environment = local.workspace_name
  }
}

module "test_instance" {
  source = "./modules/ec2-instance"

  instance_name   = "Test instance"
  subnet          = one(module.networking.subnet_ids)
  security_groups = module.networking.security_groups_ids

  instance_tags = {
    type = "webserver"
  }
  global_tags = local.global_tags
}

module "load_balancer" {
  source = "./modules/load-balancer"

  subnets         = module.networking.subnet_ids
  security_groups = module.networking.security_groups_ids
  internal        = false

  instances = [module.test_instance.id]

  listeners = [
    {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    },
    {
      instance_port     = 8080
      instance_protocol = "http"
      lb_port           = 8080
      lb_protocol       = "http"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}
