# Infisical Kubernetes Deployment

This directory contains Kubernetes manifests to deploy Infisical with PostgreSQL and Redis on a k3s cluster.

## Architecture

- **Namespace**: `infisical`
- **PostgreSQL**: Database for Infisical data
- **Redis**: Cache and session storage
- **Infisical**: Main application backend
- **Ingress**: HTTPS access via infisical.fractal-tess.xyz

## Files

| File | Description |
|------|-------------|
| `namespace.yaml` | Creates the infisical namespace |
| `secrets.yaml` | Contains all environment variables and credentials |
| `postgres.yaml` | PostgreSQL deployment with persistent storage |
| `redis.yaml` | Redis deployment |
| `infisical.yaml` | Infisical backend deployment |
| `cluster-issuer.yaml` | Let's Encrypt certificate issuer |
| `ingress.yaml` | Ingress with SSL/TLS configuration |
| `deploy.sh` | Automated deployment script |

## Prerequisites

1. k3s must be installed and running (configured in NixOS)
2. kubectl configured to access the cluster
3. ingress-nginx installed (automatically installed by k3s-post-setup)
4. cert-manager installed (automatically installed by k3s-post-setup)

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

# Create ClusterIssuer
kubectl apply -f cluster-issuer.yaml

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
- **URL**: https://infisical.fractal-tess.xyz

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

# Check certificate status
kubectl get certificate -n infisical
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

### SSL certificate not issued
```bash
kubectl describe certificate -n infisical
kubectl describe certificaterequest -n infisical
kubectl describe order -n infisical
kubectl describe challenge -n infisical
```

### Database connection issues
```bash
kubectl logs -n infisical deployment/infisical | grep -i error
```

## Notes

- The initial deployment may take 5-10 minutes for all services to be ready
- SSL certificate issuance may take a few minutes
- SMTP is configured but password is empty - update in secrets.yaml to enable email
