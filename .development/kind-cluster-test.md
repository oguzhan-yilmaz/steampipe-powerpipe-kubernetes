# Test your **local** changes

## Prerequisites

Install:

- [kind](https://kind.sigs.k8s.io/)
- `kubectl`
- `helm`
- `docker` (for building/loading images)


Use this when you want to validate the updated `powerpipe/entrypoint.sh`, mod layout, `.ppc` config, etc.

### 1. Create Kind cluster

```bash
kind create cluster --name steampipe-test
```

### 2. Build images locally

From repo root:

```bash
docker build -t steampipe-local:dev ./steampipe
docker build -t powerpipe-local:dev ./powerpipe
```

### 3. Load images into Kind

Kind nodes don’t see your host Docker images unless you load them:

```bash
kind load docker-image steampipe-local:dev --name steampipe-test
kind load docker-image powerpipe-local:dev --name steampipe-test
```

### 4. Install with image overrides

```bash
helm upgrade --install steampipe-powerpipe ./helm-chart \
  -n turbot \
  --create-namespace \
  --set global.steampipeDatabasePassword='your-test-password' \
  --set steampipe.image.repository=steampipe-local \
  --set steampipe.image.tag=dev \
  --set steampipe.image.pullPolicy=Never \
  --set powerpipe.image.repository=powerpipe-local \
  --set powerpipe.image.tag=dev \
  --set powerpipe.image.pullPolicy=Never
```

`pullPolicy: Never` is important — otherwise Kubernetes may try to pull from GHCR instead of using the loaded local images.

### 5. Verify + port-forward (same as Path A)

```bash
kubectl get pods -n turbot
kubectl port-forward -n turbot svc/powerpipe 9033:80
```

---

## What to verify for your recent changes

| Check | Command / expectation |
|-------|----------------------|
| Powerpipe env | `kubectl exec -n turbot deployment/powerpipe -- env \| grep STEAMPIPE` → `STEAMPIPE_HOST=steampipe`, password set |
| `.ppc` generated | `kubectl exec -n turbot deployment/powerpipe -- cat ~/.powerpipe/config/default.ppc` |
| No deprecated DB warnings | `kubectl logs -n turbot deployment/powerpipe` |
| Mod location | `kubectl exec -n turbot deployment/powerpipe -- ls /home/powerpipe/mod` |
| Steampipe reachable from Powerpipe | Powerpipe pod stays up; dashboard loads at `:9033` |
| K8s queries work | `kubectl exec -n turbot deployment/steampipe -- steampipe query "select count(*) from kubernetes_pod"` |
