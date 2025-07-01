# steampipe-powerpipe-kubernetes

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steampipe-powerpipe-kubernetes)](https://artifacthub.io/packages/helm/steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes)


A Helm chart to deploy [Steampipe](https://steampipe.io/) and [Powerpipe](https://powerpipe.io/) to Kubernetes.

## Helm

### Add Repo

```bash
helm repo add steampipe-powerpipe-kubernetes https://steampipe-powerpipe-kubernetes.github.io/steampipe-powerpipe-kubernetes
```

```bash
helm repo update steampipe-powerpipe-kubernetes
```

### Helm Install (latest version)

```bash
helm repo update steampipe-powerpipe-kubernetes

helm upgrade --install steampipe-powerpipe \
    -n turbot --create-namespace \
    steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes
```

### Helm Install (specific version)

```bash
helm show values steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes --version X.Y.Z > steampipe-powerpipe-values.yaml

# update the steampipe-powerpipe-values.yaml on your own accord

helm upgrade --install steampipe-powerpipe \
    -n turbot \
    -f steampipe-powerpipe-values.yaml \
    --create-namespace \
    --version X.Y.Z \
    steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes
```

## ArgoCD

You can use the `argocd-application.yaml` manifest in the Github repo: <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/blob/main/argocd-application.yaml>

```bash
kubectl apply -f https://raw.githubusercontent.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/refs/heads/main/argocd-application.yaml
```

## Configuration

### Quick Start

**Basic Setup:**
```yaml
global:
  steampipeDatabasePassword: "your-secure-password"

steampipe:
  envVars:
    INSTALL_PLUGINS: "steampipe kubernetes"

powerpipe:
  installMods:
    - github.com/turbot/steampipe-mod-kubernetes-insights
```

**Multi-Cloud Setup:**
```yaml
global:
  steampipeDatabasePassword: "your-secure-password"

steampipe:
  envVars:
    INSTALL_PLUGINS: "steampipe kubernetes aws gcp azure"
  
  secretCredentials:
    - name: aws-credentials
      directory: ".aws"
      filename: "credentials"
      content: |
        [default]
        aws_access_key_id = YOUR_ACCESS_KEY
        aws_secret_access_key = YOUR_SECRET_KEY
        region = us-east-1

powerpipe:
  installMods:
    - github.com/turbot/steampipe-mod-aws-compliance
    - github.com/turbot/steampipe-mod-gcp-compliance
    - github.com/turbot/steampipe-mod-kubernetes-compliance
```

### Steampipe Configuration

#### Plugin Management

| Parameter | Description | Default |
|-----------|-------------|---------|
| `steampipe.envVars.INSTALL_PLUGINS` | Space-separated list of plugins to install | `"steampipe kubernetes"` |

**Available Plugins:**
- **Cloud:** `aws`, `gcp`, `azure`, `alicloud`, `digitalocean`
- **Infrastructure:** `kubernetes`, `docker`, `terraform`, `vault`
- **Security:** `crowdstrike`, `okta`, `pagerduty`, `snyk`
- **Development:** `github`, `gitlab`, `jira`, `slack`, `zoom`
- **Databases:** `postgresql`, `mysql`, `mongodb`, `redis`

#### Connection Configuration

| Parameter | Description |
|-----------|-------------|
| `steampipe.config` | Steampipe connection configuration files |

**AWS Multi-Account:**
```yaml
steampipe:
  **config**:
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

### Powerpipe Configuration

#### Module Management

| Parameter | Description | Default |
|-----------|-------------|---------|
| `powerpipe.installMods` | List of Powerpipe modules to install | `["github.com/turbot/steampipe-mod-kubernetes-insights", "github.com/turbot/steampipe-mod-kubernetes-compliance"]` |

**Available Modules:**
- **Kubernetes:** `steampipe-mod-kubernetes-insights`, `steampipe-mod-kubernetes-compliance`
- **AWS:** `steampipe-mod-aws-compliance`, `steampipe-mod-aws-security`, `steampipe-mod-aws-thrifty`
- **GCP:** `steampipe-mod-gcp-compliance`, `steampipe-mod-gcp-thrifty`
- **Azure:** `steampipe-mod-azure-compliance`

**Popular Combinations:**
```yaml
# Multi-cloud compliance
powerpipe:
  installMods:
    - github.com/turbot/steampipe-mod-aws-compliance
    - github.com/turbot/steampipe-mod-gcp-compliance
    - github.com/turbot/steampipe-mod-kubernetes-compliance

# Security and compliance
powerpipe:
  installMods:
    - github.com/turbot/steampipe-mod-aws-compliance
    - github.com/turbot/steampipe-mod-aws-security
    - github.com/turbot/steampipe-mod-kubernetes-compliance
```

#### Access Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `powerpipe.ingress.enabled` | Enable external access via ingress | `false` |

**NGINX Ingress:**
```yaml
powerpipe:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - host: powerpipe.example.com
        paths:
          - path: /
            pathType: Prefix
```


#### Useful Commands

```bash
# Check status
kubectl get pods -n turbot

# Test plugin functionality
kubectl exec -n turbot deployment/steampipe -- steampipe query "select * from aws_ec2_instance"

# Check module dashboards
kubectl exec -n turbot deployment/powerpipe -- powerpipe dashboard list
```

### References

| Name                      | URL                                                                          |
| ------------------------- | ---------------------------------------------------------------------------- |
| Github Repo               | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes>           |
| Github Releases           | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/releases>  |
| Github Pages              | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/>           |
| Github Pages — Helm index | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/index.yaml> |
