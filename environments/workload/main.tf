# Example workload account: baseline in both approved regions, a hardened VPC
# and a GitHub Actions OIDC role for the application's deployment pipeline.

provider "aws" {
  region = var.home_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-landing-zone"
  }

  default_tags {
    tags = var.tags
  }
}

# Regional controls (EBS encryption, IMDSv2 defaults, Config) must be set in
# every approved region, not just the home region.
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-landing-zone"
  }

  default_tags {
    tags = var.tags
  }
}

module "baseline" {
  source = "../../modules/account-baseline"

  config_bucket_name = var.log_archive_bucket_name
  config_kms_key_arn = var.log_archive_kms_key_arn
}

module "baseline_secondary" {
  source = "../../modules/account-baseline"
  providers = {
    aws = aws.secondary
  }

  config_bucket_name = var.log_archive_bucket_name
  config_kms_key_arn = var.log_archive_kms_key_arn
  is_home_region     = false # account-wide settings are managed by the home-region baseline

  depends_on = [module.baseline]
}

module "network" {
  source = "../../modules/network"

  name               = var.vpc_name
  cidr_block         = var.vpc_cidr
  single_nat_gateway = var.environment != "prod"
}

module "github_oidc" {
  source = "../../modules/github-oidc"

  repository  = var.deploy_repository
  subjects    = ["ref:refs/heads/main", "environment:${var.environment}"]
  role_name   = "github-actions-deploy"
  policy_arns = var.deploy_policy_arns
}
