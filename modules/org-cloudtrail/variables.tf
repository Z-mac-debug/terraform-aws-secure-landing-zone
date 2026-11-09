variable "trail_name" {
  description = "Organisation trail name; must match the name the log archive bucket policy allows"
  type        = string
  default     = "organization-trail"
}

variable "log_bucket_name" {
  description = "Log archive bucket in the log archive account"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key in the log archive account that encrypts trail logs"
  type        = string
}
