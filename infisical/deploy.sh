#!/usr/bin/env bash
set -e

echo "==================================="
echo "Infisical Kubernetes Deployment"
echo "==================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Check if we can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    echo "Make sure k3s is running and kubeconfig is set up"
    exit 1
fi

echo -e "${GREEN}✓ Connected to Kubernetes cluster${NC}"
echo ""

# Apply manifests in order
echo "Step 1: Creating namespace..."
kubectl apply -f namespace.yaml
echo -e "${GREEN}✓ Namespace created${NC}"
echo ""

echo "Step 2: Creating secrets..."
kubectl apply -f secrets.yaml
echo -e "${GREEN}✓ Secrets created${NC}"
echo ""

echo "Step 3: Deploying PostgreSQL..."
kubectl apply -f postgres.yaml
echo -e "${GREEN}✓ PostgreSQL deployment started${NC}"
echo ""

echo "Step 4: Deploying Redis..."
kubectl apply -f redis.yaml
echo -e "${GREEN}✓ Redis deployment started${NC}"
echo ""

echo "Step 5: Waiting for databases to be ready..."
echo -e "${YELLOW}  Waiting for PostgreSQL...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres -n infisical --timeout=120s
echo -e "${GREEN}  ✓ PostgreSQL is ready${NC}"

echo -e "${YELLOW}  Waiting for Redis...${NC}"
kubectl wait --for=condition=ready pod -l app=redis -n infisical --timeout=120s
echo -e "${GREEN}  ✓ Redis is ready${NC}"
echo ""

echo "Step 6: Deploying Infisical backend..."
kubectl apply -f infisical.yaml
echo -e "${GREEN}✓ Infisical deployment started${NC}"
echo ""

echo "Step 7: Creating Ingress..."
kubectl apply -f ingress.yaml
echo -e "${GREEN}✓ Ingress created${NC}"
echo ""

echo "Step 8: Waiting for Infisical to be ready..."
echo -e "${YELLOW}  This may take a few minutes...${NC}"
if kubectl wait --for=condition=ready pod -l app=infisical -n infisical --timeout=300s; then
    echo -e "${GREEN}  ✓ Infisical is ready${NC}"
else
    echo -e "${YELLOW}  ⚠ Infisical is still starting. Check status with: kubectl get pods -n infisical${NC}"
fi
echo ""

echo "==================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "==================================="
echo ""
echo "Infisical should be available at:"
echo "  http://infisical.local"
echo ""
echo "Or via port-forward:"
echo "  kubectl port-forward -n infisical svc/infisical 8080:8080"
echo "  http://localhost:8080"
echo ""
echo "Useful commands:"
echo "  - Check pods: kubectl get pods -n infisical"
echo "  - Check logs: kubectl logs -n infisical deployment/infisical"
echo "  - Check ingress: kubectl get ingress -n infisical"
echo "  - Get all resources: kubectl get all -n infisical"
echo ""
