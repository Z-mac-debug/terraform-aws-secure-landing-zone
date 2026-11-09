# Log archive account: the immutable bucket every account's CloudTrail and
# Config logs land in, plus this account's own baseline.

provider "aws" {
  region = var.home_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.log_archive_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-landing-zone"
  }

  default_tags {
    tags = var.tags
  }
}

module "log_archive" {
  source = "../../modules/log-archive"

  bucket_name           = "${var.name_prefix}-org-log-archive-${var.log_archive_account_id}"
  home_region           = var.home_region
  organization_id       = var.organization_id
  management_account_id = var.management_account_id
  audit_account_id      = var.audit_account_id
  object_lock_mode      = var.object_lock_mode
  object_lock_days      = var.object_lock_days
}

module "baseline" {
  source = "../../modules/account-baseline"

  config_bucket_name = module.log_archive.bucket_name
  config_kms_key_arn = module.log_archive.kms_key_arn
}
