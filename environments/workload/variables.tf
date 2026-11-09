variable "home_region" {
  description = "Primary region"
  type        = string
  default     = "eu-west-2"
}

variable "secondary_region" {
  description = "Second approved region (DR)"
  type        = string
  default     = "eu-west-1"
}

variable "workload_account_id" {
  description = "Account ID of the workload account (created in the Workloads/Prod or Workloads/NonProd OU)"
  type        = string
}

variable "environment" {
  description = "prod or nonprod; non-prod uses a single NAT gateway to save cost"
  type        = string
  default     = "nonprod"

  validation {
    condition     = contains(["prod", "nonprod"], var.environment)
    error_message = "environment must be prod or nonprod."
  }
}

variable "log_archive_bucket_name" {
  description = "Output from environments/log-archive"
  type        = string
}

variable "log_archive_kms_key_arn" {
  description = "Output from environments/log-archive"
  type        = string
}

variable "vpc_name" {
  description = "Name of the workload VPC"
  type        = string
  default     = "workload"
}

variable "vpc_cidr" {
  description = "Workload VPC CIDR; keep unique across accounts for future peering or Transit Gateway"
  type        = string
  default     = "10.10.0.0/16"
}

variable "deploy_repository" {
  description = "GitHub repository (owner/name) allowed to deploy into this account"
  type        = string
}

variable "deploy_policy_arns" {
  description = "Policies for the deploy role; scope these to what the application actually needs"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    Project   = "secure-landing-zone"
    ManagedBy = "terraform"
  }
}
