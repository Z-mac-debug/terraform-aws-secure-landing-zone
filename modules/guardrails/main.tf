# Service control policies (SCPs): preventive guardrails that apply to every
# principal in member accounts, including account administrators. Each policy is
# kept well under the 5,120-character SCP limit.

locals {
  # Roles allowed to manage the controls below (pipelines and break-glass access).
  exempt = {
    ArnNotLike = {
      "aws:PrincipalArn" = var.exempt_role_arns
    }
  }

  # Global services that must be callable outside the allowed regions.
  # Based on the AWS example region-restriction SCP.
  global_actions = [
    "account:*", "acm:*", "aws-marketplace:*", "aws-portal:*", "billing:*", "budgets:*",
    "ce:*", "cloudfront:*", "config:*", "cur:*", "directconnect:*", "ec2:DescribeRegions",
    "ec2:DescribeTransitGateways", "ec2:DescribeVpnGateways", "fms:*", "globalaccelerator:*",
    "health:*", "iam:*", "kms:*", "networkmanager:*", "organizations:*", "pricing:*",
    "route53:*", "route53domains:*", "s3:GetAccountPublic*", "s3:ListAllMyBuckets",
    "s3:ListMultiRegionAccessPoints", "s3:PutAccountPublic*", "shield:*", "sso:*",
    "sts:*", "support:*", "tag:*", "trustedadvisor:*", "waf:*", "wafv2:*", "wellarchitected:*",
  ]

  policies = {
    baseline = {
      description = "Protect the organisation, security tooling and account hardening"
      targets     = { root = var.root_id }
      content = {
        Version = "2012-10-17"
        Statement = [
          {
            Sid      = "DenyLeavingOrganization"
            Effect   = "Deny"
            Action   = "organizations:LeaveOrganization"
            Resource = "*"
          },
          {
            Sid      = "DenyRootUser"
            Effect   = "Deny"
            Action   = "*"
            Resource = "*"
            Condition = {
              StringLike = { "aws:PrincipalArn" = "arn:aws:iam::*:root" }
            }
          },
          {
            Sid    = "ProtectSecurityServices"
            Effect = "Deny"
            Action = [
              "access-analyzer:DeleteAnalyzer",
              "cloudtrail:DeleteTrail",
              "cloudtrail:PutEventSelectors",
              "cloudtrail:StopLogging",
              "cloudtrail:UpdateTrail",
              "config:DeleteConfigurationRecorder",
              "config:DeleteDeliveryChannel",
              "config:StopConfigurationRecorder",
              "guardduty:DeleteDetector",
              "guardduty:DisassociateFromAdministratorAccount",
              "guardduty:DisassociateFromMasterAccount",
              "guardduty:UpdateDetector",
              "securityhub:DisableSecurityHub",
              "securityhub:DisassociateFromAdministratorAccount",
              "securityhub:DisassociateFromMasterAccount",
            ]
            Resource  = "*"
            Condition = local.exempt
          },
          {
            Sid    = "ProtectAccountHardening"
            Effect = "Deny"
            Action = [
              "ec2:DisableEbsEncryptionByDefault",
              "ec2:DisableImageBlockPublicAccess",
              "ec2:DisableSnapshotBlockPublicAccess",
              "ec2:ModifyInstanceMetadataDefaults",
              "iam:DeleteAccountPasswordPolicy",
              "s3:PutAccountPublicAccessBlock",
            ]
            Resource  = "*"
            Condition = local.exempt
          },
          {
            Sid      = "RequireImdsV2"
            Effect   = "Deny"
            Action   = "ec2:RunInstances"
            Resource = "arn:aws:ec2:*:*:instance/*"
            Condition = {
              StringNotEquals = { "ec2:MetadataHttpTokens" = "required" }
            }
          },
        ]
      }
    }

    region-restriction = {
      description = "Deny regional services outside the approved regions"
      targets     = { root = var.root_id }
      content = {
        Version = "2012-10-17"
        Statement = [
          {
            Sid       = "DenyUnapprovedRegions"
            Effect    = "Deny"
            NotAction = local.global_actions
            Resource  = "*"
            Condition = merge(local.exempt, {
              StringNotEquals = { "aws:RequestedRegion" = var.allowed_regions }
            })
          },
        ]
      }
    }

    deny-iam-users = {
      description = "Workloads use federated (SSO) and role-based access only - no IAM users or long-lived keys"
      targets     = { workloads = var.workloads_ou_id }
      content = {
        Version = "2012-10-17"
        Statement = [
          {
            Sid      = "DenyIamUsersAndAccessKeys"
            Effect   = "Deny"
            Action   = ["iam:CreateUser", "iam:CreateAccessKey", "iam:CreateLoginProfile"]
            Resource = "*"
          },
        ]
      }
    }

    deny-all = {
      description = "Quarantine for accounts being closed or investigated"
      targets     = { suspended = var.suspended_ou_id }
      content = {
        Version = "2012-10-17"
        Statement = [
          {
            Sid      = "DenyAll"
            Effect   = "Deny"
            Action   = "*"
            Resource = "*"
          },
        ]
      }
    }
  }

  # Encode each document up front so for_each gets uniformly typed values.
  documents = {
    for name, policy in local.policies : name => {
      description = policy.description
      content     = jsonencode(policy.content)
    }
  }

  # Keyed by label rather than ID so for_each works on the first apply, before the OUs exist.
  attachments = merge([
    for name, policy in local.policies : {
      for label, target_id in policy.targets : "${name}:${label}" => { policy = name, target = target_id }
    }
  ]...)
}

resource "aws_organizations_policy" "this" {
  for_each = local.documents

  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = each.value.content
}

resource "aws_organizations_policy_attachment" "this" {
  for_each = local.attachments

  policy_id = aws_organizations_policy.this[each.value.policy].id
  target_id = each.value.target
}
