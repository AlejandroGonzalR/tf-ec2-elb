locals {
  normalized_instance_name = replace(lower(var.instance_name), " ", "-")
  ssh_public_key_path      = file("./ssh-keys/default.pub")
}

data "aws_ami" "default" {
  count       = var.machine_image == "" ? 1 : 0
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                         = var.machine_image != "" ? var.machine_image : one(data.aws_ami.default[*].image_id)
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.instance_key.key_name
  subnet_id                   = var.subnet
  vpc_security_group_ids      = var.security_groups
  ebs_optimized               = var.ebs_optimized
  associate_public_ip_address = var.associate_public_ip_address

  user_data        = var.user_data
  user_data_base64 = data.cloudinit_config.instance_provisioning.rendered

  root_block_device {
    volume_type = var.instance_volume_type
    volume_size = var.instance_root_volume_size
  }

  tags = merge(
    var.instance_tags,
    var.global_tags,
    {
      Name = var.instance_name
    }
  )
}

resource "aws_key_pair" "instance_key" {
  key_name   = "${replace(local.normalized_instance_name, "-", "_")}_ssh_key"
  public_key = local.ssh_public_key_path
}

#####################################
# Non root user setup
#####################################

resource "random_password" "non_root_user_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "non_root_username" { # Save the non root username on the AWS Parameter Store
  name  = "/${local.normalized_instance_name}/non-root-username"
  type  = "SecureString"
  value = var.non_root_username
  tags  = var.global_tags
}

resource "aws_ssm_parameter" "non_root_user_password" { # Save the non root user password on the AWS Parameter Store
  name  = "/${local.normalized_instance_name}/non-root-user-password"
  type  = "SecureString"
  value = random_password.non_root_user_password.result
  tags  = var.global_tags
}

#####################################
# Extra IP address configuration
#####################################

resource "aws_eip" "instance_elastic_ip" {
  count    = var.associate_public_ip_address && var.assign_eip_address ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"
  tags     = var.global_tags
}
