variable "repository" {
  description = "GitHub repository allowed to assume the role, as owner/name"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.repository))
    error_message = "repository must be owner/name with no wildcards."
  }
}

variable "subjects" {
  description = "Allowed OIDC subject suffixes, e.g. ref:refs/heads/main or environment:production"
  type        = list(string)
  default     = ["ref:refs/heads/main"]
}

variable "role_name" {
  description = "Name of the IAM role GitHub Actions assumes"
  type        = string
  default     = "github-actions"
}

variable "policy_arns" {
  description = "Managed policies attached to the role (keep to least privilege)"
  type        = list(string)
  default     = []
}

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set false if the account already has one"
  type        = bool
  default     = true
}
