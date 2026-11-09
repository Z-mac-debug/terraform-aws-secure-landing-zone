# Organisation-wide detective controls, run from the delegated admin (audit)
# account: GuardDuty, Security Hub, IAM Access Analyzer and an AWS Config aggregator.

data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  region    = data.aws_region.current.region
  partition = data.aws_partition.current.partition
}

# ---------------------------------------------------------------- GuardDuty
resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

resource "aws_guardduty_organization_configuration" "this" {
  detector_id                      = aws_guardduty_detector.this.id
  auto_enable_organization_members = "ALL"
}

resource "aws_guardduty_detector_feature" "this" {
  for_each = toset(var.guardduty_features)

  detector_id = aws_guardduty_detector.this.id
  name        = each.value
  status      = "ENABLED"
}

resource "aws_guardduty_organization_configuration_feature" "this" {
  for_each = toset(var.guardduty_features)

  detector_id = aws_guardduty_detector.this.id
  name        = each.value
  auto_enable = "ALL"

  depends_on = [aws_guardduty_organization_configuration.this]
}

# ---------------------------------------------------------------- Security Hub
resource "aws_securityhub_account" "this" {
  enable_default_standards  = false
  auto_enable_controls      = true
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = true
  auto_enable_standards = "DEFAULT"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each = toset([
    "arn:${local.partition}:securityhub:${local.region}::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:${local.partition}:securityhub:${local.region}::standards/cis-aws-foundations-benchmark/v/3.0.0",
  ])

  standards_arn = each.value

  depends_on = [aws_securityhub_account.this]
}

# Pull findings from the other approved regions into the home region.
resource "aws_securityhub_finding_aggregator" "this" {
  count = length(var.linked_regions) > 0 ? 1 : 0

  linking_mode      = "SPECIFIED_REGIONS"
  specified_regions = var.linked_regions

  depends_on = [aws_securityhub_account.this]
}

# ---------------------------------------------------------------- IAM Access Analyzer
resource "aws_accessanalyzer_analyzer" "org" {
  analyzer_name = "org-external-access"
  type          = "ORGANIZATION"
}

# ---------------------------------------------------------------- AWS Config aggregator
data "aws_iam_policy_document" "config_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config_aggregator" {
  name               = "config-organization-aggregator"
  assume_role_policy = data.aws_iam_policy_document.config_assume.json
}

resource "aws_iam_role_policy_attachment" "config_aggregator" {
  role       = aws_iam_role.config_aggregator.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_aggregator" "org" {
  name = "organization"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_aggregator.arn
  }

  depends_on = [aws_iam_role_policy_attachment.config_aggregator]
}
