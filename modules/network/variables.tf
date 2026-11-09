variable "name" {
  description = "Name for the VPC and a prefix for its resources"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR. Each subnet is a /4 slice of it (a /16 gives /20 subnets)"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

variable "az_count" {
  description = "Number of availability zones to use (2-3)"
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "single_nat_gateway" {
  description = "One shared NAT gateway (cheaper, for non-prod) instead of one per AZ (resilient, for prod)"
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "CloudWatch retention for VPC flow logs"
  type        = number
  default     = 365
}
