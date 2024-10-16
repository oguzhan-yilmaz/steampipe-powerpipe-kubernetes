# steampipe-powerpipe-kubernetes

<p float="left">
  <a href="https://artifacthub.io/packages/search?repo=steampipe-powerpipe-kubernetes">
    <img src="https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steampipe-powerpipe-kubernetes" alt="Artifact Hub">
  </a>

  <a href="https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/actions/workflows/docker-publish.yaml">
    <img src="https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/actions/workflows/docker-publish.yaml/badge.svg" alt="Build and publish a steampipe and powerpipe images to ghcr.io">
  </a>

  <a href="https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/actions/workflows/helm-package-and-publish.yaml">
    <img src="https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/actions/workflows/helm-package-and-publish.yaml/badge.svg" alt="Helm package and push to Github Pages">
  </a>

  <a href="https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/actions/workflows/pages/pages-build-deployment">
    <img src="https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes/actions/workflows/pages/pages-build-deployment/badge.svg" alt="pages-build-deployment">
  </a>
</p>



A Helm chart to deploy [Steampipe](https://steampipe.io/) and [Powerpipe](https://powerpipe.io/) to Kubernetes.

## Helm

### Add Repo

```bash
helm repo add oguzhan-yilmaz https://oguzhan-yilmaz.github.io/steampipe-powerpipe-kubernetes
```

```bash
helm repo update oguzhan-yilmaz
```

### Helm Install (latest version)

```bash
helm repo update oguzhan-yilmaz

helm upgrade --install steampipe-powerpipe \
    -n turbot --create-namespace \
    oguzhan-yilmaz/steampipe-powerpipe-kubernetes
```

### Helm Install (specific version)

```bash
helm show values oguzhan-yilmaz/steampipe-powerpipe-kubernetes --version X.Y.Z > steampipe-powerpipe-values.yaml

# update the steampipe-powerpipe-values.yaml on your own accord

helm upgrade --install steampipe-powerpipe \
    -n turbot \
    -f steampipe-powerpipe-values.yaml \
    --create-namespace \
    --version X.Y.Z \
    oguzhan-yilmaz/steampipe-powerpipe-kubernetes
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
