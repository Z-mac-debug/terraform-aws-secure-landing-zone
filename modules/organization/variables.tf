variable "name_prefix" {
  description = "Prefix for account names, e.g. the company short name"
  type        = string
}

variable "log_archive_account_email" {
  description = "Unique root email address for the log archive account"
  type        = string
}

variable "audit_account_email" {
  description = "Unique root email address for the audit (security tooling) account"
  type        = string
}
