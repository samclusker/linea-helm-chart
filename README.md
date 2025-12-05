# Linea Helm Chart

![Version: 1.1.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for deploying the Linea blockchain stack on Kubernetes, including sequencer, Maru, Besu, and visualization services.

## Overview

This Helm chart provides a complete deployment solution for the Linea blockchain network components:

- **Sequencer**: Handles transaction sequencing and ordering
- **Maru**: L2 execution client for the Linea network
- **Besu**: Ethereum client providing RPC endpoints and blockchain synchronization
- **Ethstats**: Network visualization and monitoring dashboard
- **Txgen**: Optional transaction generator for testing

The chart includes production-ready features such as:
- Horizontal Pod Autoscaling (HPA) for Besu nodes
- Prometheus monitoring integration via ServiceMonitors
- Automated backups using Gemini operator
- Configurable resource limits and requests
- Comprehensive labeling and annotations for Kubernetes resource management

## Quick Start

### Prerequisites

- Kubernetes cluster (1.24+)
- Helm 3.x installed
- kubectl configured to access your cluster
- StorageClass configured for persistent volumes (default: `gp2`)

## Installation

### Basic Installation

The chart can be installed directly from the local chart directory:

```bash
helm install linea chart \
    --namespace linea \
    --create-namespace \
    --set global.namespace=linea
```

Additionally, the chart is available publicly [here](https://github.com/samclusker/linea-helm-chart/pkgs/container/linea-dev)

```bash
helm install linea-dev oci://ghcr.io/samclusker/linea-dev
```

### Custom Values

Create a `custom-values.yaml` file to override default settings:

```yaml
global:
  namespace: linea
  domain: example.com

besu:
  replicaCount: 3
  storage:
    size: 1Ti
    storageClassName: fast-ssd

sequencer:
  storage:
    size: 200Gi
```

Install with custom values:

```bash
helm install linea chart \
    --namespace linea \
    --create-namespace \
    -f custom-values.yaml
```

### Upgrading

To upgrade an existing installation:

```bash
helm upgrade linea chart \
    --namespace linea \
    -f custom-values.yaml
```

### Uninstallation

To remove the chart:

```bash
helm uninstall linea --namespace linea
```

**Note**: This will remove all resources including persistent volumes. Ensure you have backups before uninstalling.

### Verify Installation

Check that all pods are running:

```bash
kubectl get pods -n linea
```

Check the status of the Helm release:

```bash
helm status linea -n linea
```

## Secrets Management

Secrets can be deployed by populating `values.yaml` (for development purposes), but for production it is recommended that secrets are either created manually before deploying the chart or if using AWS, populate the secret names for the secrets manager addon. 

The following secrets are required (manual):
- `<release-name>-sequencer-secret`: Contains the sequencer node private key
- `<release-name>-maru-secret`: Contains Maru configuration secrets
- `<release-name>-ethstats-secret`: Contains Ethstats API secrets
- `<release-name>-txgen-secret`: Contains transaction generator sender private key

Secret name values for AWS Secrets Manager:

- `txgen.secrets.senderPkSecretName`
- `ethstats.secrets.wsSecretName`
- `maru.secrets.maruKeySecretName`
- `sequencer.secrets.sequencerKeySecretName`

#### Creating Secrets (Manual)

**Sequencer Secret**:
```bash
kubectl create secret generic <release-name>-sequencer-secret \
    --namespace linea \
    --from-literal=key=<PRIVATE_KEY_HEX>
```

**Maru Secret**:
```bash
kubectl create secret generic <release-name>-maru-secret \
    --namespace linea \
    --from-literal=key=<MARU_SECRET_KEY>
```

**Ethstats Secret**:
```bash
kubectl create secret generic <release-name>-ethstats-secret \
    --namespace linea \
    --from-literal=secret=<ETHSTATS_SECRET>
```

**Txgen Secret**:
```bash
kubectl create secret generic <release-name>-txgen-secret \
    --namespace linea \
    --from-literal=senderPk=<SENDER_PRIVATE_KEY_HEX>
```

# Deploy Linea Helm chart

There is a basic example of a Terraform project which deploys the chart in the `terraform/` directory.

```bash
cd terraform

terraform init

terraform apply -var-file terraform.prod.tfvars
```

Example `.tfvars` file:
```hcl
cluster_name            = "eks-task-production"
cluster_endpoint        = "https://foo.gr7.<region>.eks.amazonaws.com"
cluster_ca_certificate  = "...."
oidc_provider_arn       = "arn:aws:iam::<accountId>:oidc-provider/oidc.eks.<region>.amazonaws.com/id/<id>"

namespace    = "linea"
release_name = "linea"

# IRSA Configuration (optional)
create_irsa_role = true

tags = {
  managedby   = "terraform"
  project     = "eks-cluster"
}

dns_zone                = "foo.bar"
ingress_certificate_arn = "arn:aws:acm:<region>:<accountId>:certificate/<certId>"
```

## Configuration

For detailed configuration options, see the [chart README](chart/README.md) which contains the complete values reference generated by helm-docs.

Key configuration areas include:
- Resource limits and requests
- Storage configuration
- Ingress settings
- Monitoring and backup schedules
- Component-specific settings

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.fairwinds.com/stable | gemini | ^2.1.0 |
| https://prometheus-community.github.io/helm-charts | kube-prometheus-stack | ^55.0.0 |

## License

See [LICENSE](LICENSE) file for details.
