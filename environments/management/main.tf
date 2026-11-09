# Management account: the organisation, OUs, core accounts, SCP guardrails and
# the organisation trail. Run twice: first without log_archive_bucket_name (the
# archive doesn't exist yet), then again once environments/log-archive is applied.

provider "aws" {
  region = var.home_region

  default_tags {
    tags = var.tags
  }
}

locals {
  archive_ready = var.log_archive_bucket_name != null && var.log_archive_kms_key_arn != null
}

module "organization" {
  source = "../../modules/organization"

  name_prefix               = var.name_prefix
  log_archive_account_email = var.log_archive_account_email
  audit_account_email       = var.audit_account_email
}

module "guardrails" {
  source = "../../modules/guardrails"

  name_prefix      = var.name_prefix
  root_id          = module.organization.root_id
  workloads_ou_id  = module.organization.ou_ids["Workloads"]
  suspended_ou_id  = module.organization.ou_ids["Suspended"]
  allowed_regions  = var.allowed_regions
  exempt_role_arns = var.exempt_role_arns
}

module "org_cloudtrail" {
  source = "../../modules/org-cloudtrail"
  count  = local.archive_ready ? 1 : 0

  log_bucket_name = var.log_archive_bucket_name
  kms_key_arn     = var.log_archive_kms_key_arn
}

module "baseline" {
  source = "../../modules/account-baseline"
  count  = local.archive_ready ? 1 : 0

  config_bucket_name = var.log_archive_bucket_name
  config_kms_key_arn = var.log_archive_kms_key_arn
}
