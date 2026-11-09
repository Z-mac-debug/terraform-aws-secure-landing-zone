output "guardduty_detector_id" {
  description = "GuardDuty detector in the delegated admin account"
  value       = module.security_tooling.guardduty_detector_id
}

output "config_aggregator_arn" {
  description = "Organisation-wide AWS Config aggregator"
  value       = module.security_tooling.config_aggregator_arn
}
