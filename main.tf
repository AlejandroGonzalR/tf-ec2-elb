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
