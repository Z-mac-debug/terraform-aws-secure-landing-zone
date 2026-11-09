# Audit account: delegated administrator for GuardDuty, Security Hub, IAM
# Access Analyzer and the AWS Config aggregator, plus its own baseline.

provider "aws" {
  region = var.home_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.audit_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-landing-zone"
  }

  default_tags {
    tags = var.tags
  }
}

module "security_tooling" {
  source = "../../modules/security-tooling"

  linked_regions = [for r in var.allowed_regions : r if r != var.home_region]
}

module "baseline" {
  source = "../../modules/account-baseline"

  config_bucket_name = var.log_archive_bucket_name
  config_kms_key_arn = var.log_archive_kms_key_arn
}
