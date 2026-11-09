output "organization_id" {
  description = "Feed into environments/log-archive"
  value       = module.organization.organization_id
}

output "ou_ids" {
  description = "OU name to ID"
  value       = module.organization.ou_ids
}

output "log_archive_account_id" {
  description = "Feed into environments/log-archive"
  value       = module.organization.log_archive_account_id
}

output "audit_account_id" {
  description = "Feed into environments/log-archive and environments/audit"
  value       = module.organization.audit_account_id
}

output "scp_ids" {
  description = "SCP name to policy ID"
  value       = module.guardrails.policy_ids
}
