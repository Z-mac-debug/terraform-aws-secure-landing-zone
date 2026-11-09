output "organization_id" {
  description = "AWS Organizations ID (o-xxxxxxxxxx)"
  value       = aws_organizations_organization.this.id
}

output "root_id" {
  description = "ID of the organisation root"
  value       = local.root_id
}

output "ou_ids" {
  description = "Map of OU name to ID, including Workloads/Prod and Workloads/NonProd"
  value = merge(
    { for name, ou in aws_organizations_organizational_unit.top : name => ou.id },
    { for name, ou in aws_organizations_organizational_unit.workloads : "Workloads/${name}" => ou.id },
  )
}

output "log_archive_account_id" {
  description = "Account ID of the log archive account"
  value       = aws_organizations_account.log_archive.id
}

output "audit_account_id" {
  description = "Account ID of the audit account"
  value       = aws_organizations_account.audit.id
}
