variable "region" {
  description = "Region of the EKS cluster"
  type        = string
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the Helm release"
  type        = string
  default     = "linea"
}

variable "release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "linea"
}

variable "dns_zone" {
  description = "DNS zone for the Helm release"
  type        = string
  default     = "foo.bar"
}

variable "ingress_certificate_arn" {
  description = "ARN of the certificate for the ingress"
  type        = string
  default     = null
}

variable "use_aws_secrets" {
  description = "Whether to use AWS Secrets Manager for the secrets"
  type        = bool
  default     = true
}

variable "create_irsa_role" {
  description = "Whether to create an IAM role for the service account (IRSA)"
  type        = bool
  default     = true
}

variable "irsa_additional_policies" {
  description = "Additional IAM policy ARNs to attach to the IRSA role (policy name: policy ARN, e.g. { \"AWSSecretsManagerClientReadOnlyAccess\" = \"arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess\" })"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
