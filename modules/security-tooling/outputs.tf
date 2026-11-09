output "guardduty_detector_id" {
  description = "GuardDuty detector ID in the delegated admin account"
  value       = aws_guardduty_detector.this.id
}

output "access_analyzer_arn" {
  description = "Organisation-wide IAM Access Analyzer ARN"
  value       = aws_accessanalyzer_analyzer.org.arn
}

output "config_aggregator_arn" {
  description = "AWS Config organisation aggregator ARN"
  value       = aws_config_configuration_aggregator.org.arn
}
