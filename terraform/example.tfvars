cluster_name           = "eks-task-production"
cluster_endpoint       = "https://00000.gr7.eu-north-1.eks.amazonaws.com"
cluster_ca_certificate = "00000000"
oidc_provider_arn      = "arn:aws:iam::000000000000:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/00000000"

namespace    = "linea"
release_name = "linea"

# IRSA Configuration (optional)
create_irsa_role = true

tags = {
  managedby = "terraform"
  project   = "eks-cluster"
}

dns_zone                = "foo.bar"
ingress_certificate_arn = "arn:aws:acm:eu-north-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"