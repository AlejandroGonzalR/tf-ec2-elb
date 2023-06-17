locals {
  instance_non_root_user_provisioning = "./provisioning/non_root_user.sh"
}

data "cloudinit_config" "instance_provisioning" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile(local.instance_non_root_user_provisioning, {
      username = var.non_root_username
      password = random_password.non_root_user_password.result
    })
  }

  dynamic "part" {
    for_each = var.user_data_base64_parts

    content {
      content_type = part.value["content_type"]
      content      = part.value["content"]
      filename     = part.value["filename"]
    }
  }
}
