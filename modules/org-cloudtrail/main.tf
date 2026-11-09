# One multi-region organisation trail, created in the management account and
# delivered to the log archive account. Member accounts can't stop or edit it.
resource "aws_cloudtrail" "org" {
  #checkov:skip=CKV2_AWS_10:Logs are centralised in the S3 archive and ingested by the SIEM from there.
  #checkov:skip=CKV_AWS_252:Delivery notifications aren't needed; the SIEM polls the archive.
  name                          = var.trail_name
  s3_bucket_name                = var.log_bucket_name
  kms_key_id                    = var.kms_key_arn
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  insight_selector {
    insight_type = "ApiErrorRateInsight"
  }
}
