# Optional: IAM role for service account
module "linea_app_irsa" {
  count = var.use_aws_secrets || var.create_irsa_role ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.28"

  role_name_prefix = "linea-app-"

  # Optional: Grant permissions to access Secrets Manager
  # Optional: Additional IAM policy ARNs to attach to the IRSA role
  role_policy_arns = merge(
    var.use_aws_secrets ? {
      "AWSSecretsManagerClientReadOnlyAccess" = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
    } : {},
    { for idx, policy in var.irsa_additional_policies : "additional-policy-${idx}" => policy }
  )

  role_description = "IAM role for Linea application service account"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${var.release_name}"]
    }
  }

  tags = var.tags
}

resource "helm_release" "linea" {
  name             = var.release_name
  namespace        = var.namespace
  repository       = null
  chart            = "${path.module}/../chart"
  create_namespace = true
  wait             = true
  atomic           = true
  timeout          = 600

  values = [templatefile("${path.module}/values/values.yaml.tftpl", {
    global = {
      domain = var.dns_zone
      region = var.region
    },
    ingress = {
      annotations = {
        certificate_arn = var.ingress_certificate_arn
      }
    }
    service_account = {
      annotations = {
        sa_role_arn = module.linea_app_irsa[0].iam_role_arn
      }
    }
  })]
}