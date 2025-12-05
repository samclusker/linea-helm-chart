output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.linea.name
}

output "helm_release_namespace" {
  description = "Namespace of the Helm release"
  value       = helm_release.linea.namespace
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = helm_release.linea.status
}

output "irsa_role_arn" {
  description = "ARN of the IAM role for service account (if created)"
  value       = var.use_aws_secrets ? module.linea_app_irsa[0].iam_role_arn : null
}

output "irsa_role_name" {
  description = "Name of the IAM role for service account (if created)"
  value       = var.use_aws_secrets ? module.linea_app_irsa[0].iam_role_name : null
}

output "service_account_name" {
  description = "Name of the service account used by the Helm release"
  value       = var.release_name
}
