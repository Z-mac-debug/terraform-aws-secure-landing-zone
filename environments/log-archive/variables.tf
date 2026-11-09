variable "home_region" {
  description = "Primary region for the landing zone"
  type        = string
  default     = "eu-west-2"
}

variable "name_prefix" {
  description = "Short company or project name; used in the bucket name"
  type        = string
}

variable "organization_id" {
  description = "Output organization_id from environments/management"
  type        = string
}

variable "management_account_id" {
  description = "Management account ID"
  type        = string
}

variable "log_archive_account_id" {
  description = "Output log_archive_account_id from environments/management"
  type        = string
}

variable "audit_account_id" {
  description = "Output audit_account_id from environments/management"
  type        = string
}

variable "object_lock_mode" {
  description = "GOVERNANCE or COMPLIANCE write-once retention"
  type        = string
  default     = "GOVERNANCE"
}

variable "object_lock_days" {
  description = "Write-once retention period in days"
  type        = number
  default     = 365
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    Project   = "secure-landing-zone"
    ManagedBy = "terraform"
  }
}
