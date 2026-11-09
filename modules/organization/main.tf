resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "access-analyzer.amazonaws.com",
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "malware-protection.guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
  ]

  enabled_policy_types = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  root_id = aws_organizations_organization.this.roots[0].id

  top_level_ous = toset(["Security", "Infrastructure", "Workloads", "Sandbox", "Suspended"])
  workload_ous  = toset(["Prod", "NonProd"])
}

resource "aws_organizations_organizational_unit" "top" {
  for_each = local.top_level_ous

  name      = each.value
  parent_id = local.root_id
}

resource "aws_organizations_organizational_unit" "workloads" {
  for_each = local.workload_ous

  name      = each.value
  parent_id = aws_organizations_organizational_unit.top["Workloads"].id
}

# Core accounts. Both live in the Security OU and are never closed by Terraform.
resource "aws_organizations_account" "log_archive" {
  name                       = "${var.name_prefix}-log-archive"
  email                      = var.log_archive_account_email
  parent_id                  = aws_organizations_organizational_unit.top["Security"].id
  role_name                  = "OrganizationAccountAccessRole"
  iam_user_access_to_billing = "DENY"
  close_on_deletion          = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [role_name, iam_user_access_to_billing]
  }
}

resource "aws_organizations_account" "audit" {
  name                       = "${var.name_prefix}-audit"
  email                      = var.audit_account_email
  parent_id                  = aws_organizations_organizational_unit.top["Security"].id
  role_name                  = "OrganizationAccountAccessRole"
  iam_user_access_to_billing = "DENY"
  close_on_deletion          = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [role_name, iam_user_access_to_billing]
  }
}

# The audit account runs the organisation's security tooling, so the management
# account (which SCPs cannot restrict) is used for as little as possible.
resource "aws_guardduty_organization_admin_account" "audit" {
  admin_account_id = aws_organizations_account.audit.id

  depends_on = [aws_organizations_organization.this]
}

resource "aws_securityhub_organization_admin_account" "audit" {
  admin_account_id = aws_organizations_account.audit.id

  depends_on = [aws_organizations_organization.this]
}

resource "aws_organizations_delegated_administrator" "audit" {
  for_each = toset(["access-analyzer.amazonaws.com", "config.amazonaws.com"])

  account_id        = aws_organizations_account.audit.id
  service_principal = each.value

  depends_on = [aws_organizations_organization.this]
}
