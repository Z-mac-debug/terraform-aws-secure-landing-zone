variable "name_prefix" {
  description = "Prefix for policy names"
  type        = string
}

variable "root_id" {
  description = "Organisation root ID; baseline and region policies attach here"
  type        = string
}

variable "workloads_ou_id" {
  description = "Workloads OU ID; the no-IAM-users policy attaches here"
  type        = string
}

variable "suspended_ou_id" {
  description = "Suspended OU ID; the deny-all policy attaches here"
  type        = string
}

variable "allowed_regions" {
  description = "Regions where regional services may be used"
  type        = list(string)
  default     = ["eu-west-2", "eu-west-1"]
}

variable "exempt_role_arns" {
  description = "Role ARN patterns exempt from the protective statements (pipeline and break-glass roles)"
  type        = list(string)
  default     = ["arn:aws:iam::*:role/OrganizationAccountAccessRole"]
}
