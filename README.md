# steampipe-powerpipe-kubernetes

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steampipe-powerpipe-kubernetes)](https://artifacthub.io/packages/helm/steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes)

A Helm chart to deploy [Steampipe](https://steampipe.io/) and [Powerpipe](https://powerpipe.io/) to Kubernetes.

## Helm

```bash
helm repo add steampipe-powerpipe-kubernetes https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes
helm repo update steampipe-powerpipe-kubernetes
```

### Install

```bash
helm show values steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes > values.yaml  # --version X.Y.Z
# edit values.yaml

helm upgrade --install steampipe-powerpipe \
    -n turbot --create-namespace \
    -f values.yaml \
    steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes  # --version X.Y.Z
```

Tagged releases (`v*.*.*`) publish Docker images to GHCR, package the chart, and update the Helm repo index. See [Releases](https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/releases) for bundled Steampipe/Powerpipe versions.

## ArgoCD

Apply the manifest from the repo, or use the versioned asset from a release (`argocd-application-X.Y.Z.yaml`):

```bash
kubectl apply -f https://raw.githubusercontent.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/refs/heads/main/argocd-application.yaml
```

## Local Development

**Docker Compose** — configure `.env`, then:

```bash
docker compose up --build
```

- Steampipe: `localhost:9193`
- Powerpipe: `http://localhost:9033`

**Kind** — see [.development/kind-cluster-test.md](.development/kind-cluster-test.md).

## Configuration

### Quick Start

```yaml
global:
  steampipeDatabasePassword: "your-secure-password"

steampipe:
  envVars:
    INSTALL_PLUGINS: "steampipe kubernetes aws gcp azure"

powerpipe:
  installMods:
    - github.com/turbot/steampipe-mod-aws-compliance
    - github.com/turbot/steampipe-mod-gcp-compliance
    - github.com/turbot/steampipe-mod-kubernetes-compliance
```

Powerpipe connects to Steampipe via `STEAMPIPE_HOST` and `STEAMPIPE_DATABASE_PASSWORD` (set from `global.steampipeDatabasePassword`).

### Connection Configuration

| Parameter | Description |
|-----------|-------------|
| `steampipe.config` | Steampipe connection configuration files |

**AWS Multi-Account:**

```yaml
steampipe:
  config:
    aws.spc: |
      connection "aws_production" {
        plugin  = "aws"
        profile = "production"
        regions = ["us-east-1", "us-west-2", "eu-west-1"]
      }
      connection "aws_staging" {
        plugin  = "aws"
        profile = "staging"
        regions = ["us-east-1", "us-west-2"]
      }
```

**Multi-Profile AWS** — mount credentials and config via `steampipe.secretCredentials`:

```yaml
steampipe:
  secretCredentials:
    - name: aws-credentials
      directory: ".aws"
      filename: "credentials"
      content: |
        [production]
        aws_access_key_id = PROD_ACCESS_KEY
        aws_secret_access_key = PROD_SECRET_KEY
        region = us-east-1
    - name: aws-config
      directory: ".aws"
      filename: "config"
      content: |
        [profile production]
        region = us-east-1
        output = json
```

**GCP Service Account:**

```yaml
steampipe:
  secretCredentials:
    - name: gcp-service-account
      directory: "."
      filename: "gcp-service-account.json"
      content: |
        {
          "type": "service_account",
          "project_id": "my-project",
          "private_key_id": "...",
          "private_key": "...",
          "client_email": "..."
        }
```

### Powerpipe Mods

| Parameter | Description | Default |
|-----------|-------------|---------|
| `powerpipe.installMods` | Mods to install at runtime | kubernetes-insights, kubernetes-compliance |

```yaml
powerpipe:
  installMods:
    - github.com/turbot/steampipe-mod-aws-compliance
    - github.com/turbot/steampipe-mod-gcp-compliance
    - github.com/turbot/steampipe-mod-kubernetes-compliance
```

### Useful Commands

```bash
kubectl get pods -n turbot

kubectl exec -n turbot deployment/steampipe -- steampipe query "select * from kubernetes_pod limit 5"

kubectl exec -n turbot deployment/powerpipe -- powerpipe dashboard list

kubectl port-forward -n turbot svc/powerpipe 9033:80
```

## References

| Name | URL |
|------|-----|
| Github Repo | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes> |
| Github Releases | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/releases> |
| Github Pages | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/> |
| Helm index | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/index.yaml> |
