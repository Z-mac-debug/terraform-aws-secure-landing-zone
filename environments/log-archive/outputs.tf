output "log_archive_bucket_name" {
  description = "Feed into the management, audit and workload environments"
  value       = module.log_archive.bucket_name
}

output "log_archive_kms_key_arn" {
  description = "Feed into the management, audit and workload environments"
  value       = module.log_archive.kms_key_arn
}
