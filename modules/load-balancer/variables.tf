variable "name" {
  description = "The name of the ELB"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "The prefix name of the ELB"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the ELB"
  type        = list(string)
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the ELB"
  type        = list(string)
}

variable "internal" {
  description = "If true, ELB will be an internal ELB"
  type        = bool
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "connection_draining" {
  description = "Boolean to enable connection draining"
  type        = bool
  default     = false
}

variable "connection_draining_timeout" {
  description = "The time in seconds to allow for connections to drain"
  type        = number
  default     = 300
}

variable "global_tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "listeners" {
  description = "A list of objects describing the HTTP(S) listeners or TCP ports for this ELB."
  type = list(
    object({
      instance_port      = number
      instance_protocol  = string
      lb_port            = number
      lb_protocol        = string
      ssl_certificate_id = optional(string)
    })
  )
}

variable "access_logs" {
  description = "An access logs block"
  type = object({
    enabled = optional(bool)
    bucket  = optional(string)
    prefix  = optional(string)
  })
  default = null
}

variable "health_check" {
  description = "A health check block"
  type        = map(string)
}

variable "instances" {
  description = "List of instances ID to place in the ELB pool"
  type        = list(string)
}

variable "elb_root_domain" {
  description = "The root domain name to use for API gateway, through Route53 implementation."
  type        = string
  default     = "test.com."
}

variable "domain_name" {
  description = "The custom domain name to use for API gateway."
  type        = string
  default     = null
}

variable "domain_name_certificate_arn" {
  description = "The ARN of an AWS-managed certificate that will be used by the endpoint for the domain name."
  type        = string
  default     = null
}
