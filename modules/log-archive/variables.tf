variable "bucket_name" {
  description = "Globally unique name for the log archive bucket"
  type        = string
}

variable "home_region" {
  description = "Region where the organisation trail and this bucket live"
  type        = string
}

variable "organization_id" {
  description = "AWS Organizations ID (o-xxxxxxxxxx)"
  type        = string
}

variable "management_account_id" {
  description = "Management account ID, which owns the organisation trail"
  type        = string
}

variable "audit_account_id" {
  description = "Audit account ID, granted read access for investigations"
  type        = string
}

variable "trail_name" {
  description = "Name of the organisation trail allowed to write here"
  type        = string
  default     = "organization-trail"
}

variable "retention_days" {
  description = "Days to keep logs before expiry"
  type        = number
  default     = 400
}

variable "object_lock_mode" {
  description = "GOVERNANCE (privileged users can override) or COMPLIANCE (nobody can, including root)"
  type        = string
  default     = "GOVERNANCE"

  validation {
    condition     = contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_mode)
    error_message = "object_lock_mode must be GOVERNANCE or COMPLIANCE."
  }
}

variable "object_lock_days" {
  description = "Write-once retention period for each log object"
  type        = number
  default     = 365

  validation {
    condition     = var.object_lock_days > 0
    error_message = "object_lock_days must be positive."
  }
}
