# Infisical Kubernetes Deployment

This directory contains Kubernetes manifests to deploy Infisical with PostgreSQL and Redis on a k3s cluster.

## Architecture

- **Namespace**: `infisical`
- **PostgreSQL**: Database for Infisical data
- **Redis**: Cache and session storage
- **Infisical**: Main application backend
- **Ingress**: HTTP access via infisical.local

## Files

| File | Description |
|------|-------------|
| `namespace.yaml` | Creates the infisical namespace |
| `secrets.yaml` | Contains all environment variables and credentials |
| `postgres.yaml` | PostgreSQL deployment with persistent storage |
| `redis.yaml` | Redis deployment |
| `infisical.yaml` | Infisical backend deployment |
| `ingress.yaml` | Ingress configuration |
| `deploy.sh` | Automated deployment script |

## Prerequisites

1. k3s must be installed and running (configured in NixOS)
2. kubectl configured to access the cluster
3. ingress-nginx installed (automatically installed by k3s-post-setup)


## Deployment

### Option 1: Automated (Recommended)

```bash
cd /home/fractal-tess/nixos/k8s/infisical
./deploy.sh
```

### Option 2: Manual

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Create secrets
kubectl apply -f secrets.yaml

# Deploy databases
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml

# Wait for databases
kubectl wait --for=condition=ready pod -l app=postgres -n infisical --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis -n infisical --timeout=120s

# Deploy Infisical
kubectl apply -f infisical.yaml

# Create ingress
kubectl apply -f ingress.yaml
```

## Access

After deployment, Infisical will be available at:
- **URL**: http://infisical.local

Or via port-forward:
```bash
kubectl port-forward -n infisical svc/infisical 8080:8080
```
Then open: http://localhost:8080

## Monitoring

```bash
# Check all resources
kubectl get all -n infisical

# Check pods
kubectl get pods -n infisical

# View logs
kubectl logs -n infisical deployment/infisical
kubectl logs -n infisical deployment/postgres
kubectl logs -n infisical deployment/redis

# Check ingress
kubectl get ingress -n infisical


```

## Secrets

All sensitive data is stored in `secrets.yaml`. To update secrets:

1. Edit `secrets.yaml`
2. Apply changes: `kubectl apply -f secrets.yaml`
3. Restart deployments: `kubectl rollout restart deployment/infisical -n infisical`

## Troubleshooting

### Pod stuck in Pending
```bash
kubectl describe pod -n infisical <pod-name>
```

### Database connection issues
```bash
kubectl logs -n infisical deployment/infisical | grep -i error
```

## Notes

- The initial deployment may take 5-10 minutes for all services to be ready
- SMTP is configured but password is empty - update in secrets.yaml to enable email
