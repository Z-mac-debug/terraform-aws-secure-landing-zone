variable "home_region" {
  description = "Primary region for the landing zone"
  type        = string
  default     = "eu-west-2"
}

variable "allowed_regions" {
  description = "Approved regions; Security Hub findings from the others are aggregated into home_region"
  type        = list(string)
  default     = ["eu-west-2", "eu-west-1"]
}

variable "audit_account_id" {
  description = "Output audit_account_id from environments/management"
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Output from environments/log-archive"
  type        = string
}

variable "log_archive_kms_key_arn" {
  description = "Output from environments/log-archive"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    Project   = "secure-landing-zone"
    ManagedBy = "terraform"
  }
}
