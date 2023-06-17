locals {
  workspace_name = "testing-ec2_elb"

  subnets_newbits = 9
  vpc_cidr_block  = "10.0.0.0/16"

  availabilities_zones_suffixes = ["A", "B"]
}

module "networking" {
  source = "./modules/networking"

  workspace_name = local.workspace_name
  vpc_cidr_block = local.vpc_cidr_block

  subnets = [
    for idx, subnet in local.availabilities_zones_suffixes :
    {
      name                    = "Test instance ${subnet}"
      cidr_block              = cidrsubnet(local.vpc_cidr_block, local.subnets_newbits, idx)
      availability_zone       = "us-east-1${subnet}"
      map_public_ip_on_launch = false
    }
  ]

  security_groups = [
    {
      name        = "ssh-security-group"
      description = "Security group for the SSH based resources"
      ingress = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
    {
      name        = "linux-remote-desktop"
      description = "Allows Linux Remote Desktop traffic using XRDP"
      ingress = [
        {
          from_port   = 3389
          to_port     = 3389
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
  ]

  global_tags = local.global_tags
}
