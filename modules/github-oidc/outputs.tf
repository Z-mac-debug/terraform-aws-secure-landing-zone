output "role_arn" {
  description = "ARN of the role to put in the workflow's aws-actions/configure-aws-credentials step"
  value       = aws_iam_role.this.arn
}
