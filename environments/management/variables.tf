variable "home_region" {
  description = "Primary region for the landing zone"
  type        = string
  default     = "eu-west-2"
}

variable "allowed_regions" {
  description = "Regions where member accounts may use regional services"
  type        = list(string)
  default     = ["eu-west-2", "eu-west-1"]
}

variable "name_prefix" {
  description = "Short company or project name used in account and policy names"
  type        = string
}

variable "log_archive_account_email" {
  description = "Unique root email for the log archive account"
  type        = string
}

variable "audit_account_email" {
  description = "Unique root email for the audit account"
  type        = string
}

variable "exempt_role_arns" {
  description = "Role ARN patterns exempt from protective SCP statements"
  type        = list(string)
  default     = ["arn:aws:iam::*:role/OrganizationAccountAccessRole"]
}

variable "log_archive_bucket_name" {
  description = "Log archive bucket (output of environments/log-archive). Leave null on the first run"
  type        = string
  default     = null
}

variable "log_archive_kms_key_arn" {
  description = "Log archive KMS key ARN (output of environments/log-archive). Leave null on the first run"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    Project   = "secure-landing-zone"
    ManagedBy = "terraform"
  }
}
