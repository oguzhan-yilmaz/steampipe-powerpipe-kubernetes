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

### Install from local chart

```bash
helm upgrade --install steampipe-powerpipe . \
    -n turbot --create-namespace \
    -f values.yaml
```

Tagged releases (`v*.*.*`) publish images to GHCR, package this chart, and update the Helm repo index. Release assets include `steampipe-powerpipe-kubernetes-X.Y.Z.tgz` and `argocd-application-X.Y.Z.yaml`.

## ArgoCD

```bash
kubectl apply -f https://raw.githubusercontent.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/refs/heads/main/argocd-application.yaml
```

For a pinned chart version, download `argocd-application-X.Y.Z.yaml` from [Releases](https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/releases).

## Configuration

See the [project README](../README.md#configuration) for values examples (plugins, credentials, mods).

## References

| Name | URL |
|------|-----|
| Github Repo | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes> |
| Github Releases | <https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/releases> |
| Github Pages | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/> |
| Helm index | <https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes/index.yaml> |

---

Maintainers: [oguzhan-yilmaz](https://github.com/oguzhan-yilmaz)
