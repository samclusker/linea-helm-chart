# Optional: IAM role for service account
module "linea_app_irsa" {
  count = var.use_aws_secrets || var.create_irsa_role ? 1 : 0

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts?ref=7279fc4"

  name = "linea-app"

  # Optional: Grant permissions to access Secrets Manager
  # Optional: Additional IAM policy ARNs to attach to the IRSA role
  policies = merge(
    var.use_aws_secrets ? {
      "AWSSecretsManagerClientReadOnlyAccess" = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
    } : {},
    { for idx, policy in var.irsa_additional_policies : "additional-policy-${idx}" => policy }
  )

  description = "IAM role for Linea application service account"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${var.release_name}"]
    }
  }

  tags = var.tags
}

data "external" "chart_hash" {
  program = ["bash", "-c", <<-EOT
    find ../chart -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $1}' | jq -R '{"hash":.}'
  EOT
  ]
}

resource "helm_release" "linea" {
  name             = var.release_name
  namespace        = var.namespace
  chart            = "${path.module}/../chart"
  create_namespace = true
  wait             = true
  atomic           = true
  timeout          = 300

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
        sa_role_arn = module.linea_app_irsa[0].arn
      }
    }
  })]

  set = [{
    name  = "chart.hash"
    value = data.external.chart_hash.result.hash
  }]
}