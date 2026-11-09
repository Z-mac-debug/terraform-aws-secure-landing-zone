output "policy_ids" {
  description = "Map of SCP name to policy ID"
  value       = { for name, policy in aws_organizations_policy.this : name => policy.id }
}
