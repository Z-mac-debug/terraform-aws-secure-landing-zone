variable "guardduty_features" {
  description = "GuardDuty protection plans to enable here and auto-enable for every member account"
  type        = list(string)
  default     = ["S3_DATA_EVENTS", "EBS_MALWARE_PROTECTION", "RDS_LOGIN_EVENTS", "LAMBDA_NETWORK_LOGS"]
}

variable "linked_regions" {
  description = "Other approved regions whose Security Hub findings are aggregated into this one"
  type        = list(string)
  default     = ["eu-west-1"]
}
