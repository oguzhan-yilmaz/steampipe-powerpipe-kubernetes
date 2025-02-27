# steampipe-powerpipe-kubernetes

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steampipe-powerpipe-kubernetes)](https://artifacthub.io/packages/helm/steampipe-powerpipe-kubernetes/steampipe-powerpipe-kubernetes)


A Helm chart to deploy [Steampipe](https://steampipe.io/) and [Powerpipe](https://powerpipe.io/) to Kubernetes.

## Helm

### Add Repo

```bash
helm repo add steampipe-powerpipe-kubernetesoguzhan-yilmaz https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes
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

### References

| Name                      | URL                                                                          |
| ------------------------- | ---------------------------------------------------------------------------- |
| Github Repo               | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes>           |
| Github Releases           | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/releases>  |
| Github Pages              | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/>           |
| Github Pages — Helm index | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/index.yaml> |

---

- Maintainers: oguzhan-yilmaz <https://github.com/oguzhan-yilmaz>
