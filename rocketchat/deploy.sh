#!/usr/bin/env bash
set -e

echo "==================================="
echo "Rocket.Chat Kubernetes Deployment"
echo "==================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${GREEN}Connected to Kubernetes cluster${NC}"
echo ""

echo "Step 1: Creating namespace..."
kubectl apply -f namespace.yaml
echo -e "${GREEN}Namespace created${NC}"
echo ""

echo "Step 2: Creating secrets..."
kubectl apply -f secrets.yaml
echo -e "${GREEN}Secrets created${NC}"
echo ""

echo "Step 3: Deploying MongoDB..."
kubectl apply -f mongodb.yaml
echo -e "${GREEN}MongoDB deployment started${NC}"
echo ""

echo "Step 4: Waiting for MongoDB to be ready..."
echo -e "${YELLOW}  Waiting for MongoDB...${NC}"
kubectl wait --for=condition=ready pod -l app=mongodb -n rocketchat --timeout=120s
echo -e "${GREEN}  MongoDB ready${NC}"
echo ""

echo "Step 5: Deploying Rocket.Chat..."
kubectl apply -f rocketchat.yaml
echo -e "${GREEN}Rocket.Chat deployment started${NC}"
echo ""

echo "Step 6: Waiting for Rocket.Chat to be ready..."
echo -e "${YELLOW}  This may take a few minutes...${NC}"
if kubectl wait --for=condition=ready pod -l app=rocketchat -n rocketchat --timeout=300s; then
    echo -e "${GREEN}  Rocket.Chat is ready${NC}"
else
    echo -e "${YELLOW}  Rocket.Chat is still starting. Check status with: kubectl get pods -n rocketchat${NC}"
fi
echo ""

echo "==================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "==================================="
echo ""
echo "Rocket.Chat should be accessible via port-forward:"
echo "  kubectl port-forward -n rocketchat svc/rocketchat 3000:3000"
echo ""
echo "Then open: http://localhost:3000"
echo ""
echo "Note: Update secrets.yaml with your actual ROOT_URL before deploying."
echo ""
echo "Useful commands:"
echo "  kubectl get pods -n rocketchat"
echo "  kubectl logs -n rocketchat deployment/rocketchat"
echo "  kubectl logs -n rocketchat deployment/mongodb"
echo ""
