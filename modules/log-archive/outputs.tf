output "bucket_name" {
  description = "Log archive bucket name"
  value       = aws_s3_bucket.logs.id
}

output "bucket_arn" {
  description = "Log archive bucket ARN"
  value       = aws_s3_bucket.logs.arn
}

output "kms_key_arn" {
  description = "KMS key that encrypts the archive"
  value       = aws_kms_key.logs.arn
}
