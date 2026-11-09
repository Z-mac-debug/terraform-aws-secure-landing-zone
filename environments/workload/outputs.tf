output "vpc_id" {
  description = "Workload VPC ID"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnets for application workloads"
  value       = module.network.private_subnet_ids
}

output "deploy_role_arn" {
  description = "Role for the application's GitHub Actions deployments"
  value       = module.github_oidc.role_arn
}
