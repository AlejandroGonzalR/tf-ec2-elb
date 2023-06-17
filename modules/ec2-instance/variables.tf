variable "instance_name" {
  type        = string
  description = "The tag name of the instance"
}

variable "machine_image" {
  type        = string
  description = "The AMI to use for the instance. By default it is the AMI provided by Amazon with Ubuntu 16.04"
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t4g.nano"
}

variable "subnet" {
  type        = string
  description = "VPC Subnet ID the instance is launched in"
}

variable "security_groups" {
  description = "A list of Security Group IDs to associate with EC2 instance."
  type        = list(string)
  default     = []
}

variable "instance_volume_type" {
  description = "The volume type for the instance"
  default     = "gp3"
}

variable "instance_root_volume_size" {
  description = "The volume size for the instance"
  default     = 20
}

variable "ebs_optimized" {
  type        = bool
  description = "Launched EC2 instance will be EBS-optimized"
  default     = true
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with the instance"
  default     = false
}

variable "assign_eip_address" {
  type        = bool
  description = "Assign an Elastic IP address to the instance"
  default     = false
}

variable "non_root_username" {
  type        = string
  description = "Username to create a non root user"
  default     = "test"
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; use `user_data_base64` instead"
  default     = null
}

variable "user_data_base64_parts" {
  type = list(object({
    content      = string,
    content_type = optional(string),
    filename     = optional(string),

  }))
  description = "Can be used instead of `user_data` to pass base64-encoded binary parts data directly. Used to avoid corruption on UTF-8 encoding strings or input multiple separated scripts"
  default     = []
}

variable "instance_tags" {
  type        = map(string)
  description = "Specific tags for EC2 instance"
  default     = {}
}

variable "global_tags" {
  type        = map(string)
  description = "Default tags for all resources"
  default     = {}
}
