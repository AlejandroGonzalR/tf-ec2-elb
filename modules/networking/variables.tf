variable "workspace_name" {
  description = "The name of the network environment"
}

variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC"
}

variable "subnets" {
  description = "List of subnets being created in the VPC"
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
  default = []
}

variable "security_groups" {
  description = "List of security groups being created in this VPC"
  type = list(object({
    name        = string
    description = string
    ingress = optional(list(object({
      description = optional(string)
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })))
    egress = optional(list(object({
      description = optional(string)
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })))
    internal_ingress = optional(list(object({
      description           = optional(string)
      from_port             = number
      to_port               = number
      protocol              = string
      source_security_group = string
    })))
  }))
  default = []
}

variable "global_tags" {
  type        = map(string)
  description = "Default tags for all resources"
  default     = {}
}
