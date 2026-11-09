variable "config_bucket_name" {
  description = "Log archive bucket that receives AWS Config history and snapshots"
  type        = string
}

variable "config_kms_key_arn" {
  description = "KMS key (in the log archive account) used to encrypt Config deliveries"
  type        = string
}

variable "is_home_region" {
  description = "True for the home-region instance, which also manages account-wide settings (password policy, S3 account block, Config SLR, global resource recording)"
  type        = bool
  default     = true
}

variable "create_config_service_linked_role" {
  description = "Create the AWS Config service-linked role. Set false if the account already has it"
  type        = bool
  default     = true
}
