#!/usr/bin/env bash
set -e

echo "==================================="
echo "Plane Kubernetes Deployment"
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

echo "Step 3: Deploying infrastructure (PostgreSQL, Redis, RabbitMQ, MinIO)..."
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
kubectl apply -f rabbitmq.yaml
kubectl apply -f minio.yaml
echo -e "${GREEN}Infrastructure deployments started${NC}"
echo ""

echo "Step 4: Waiting for infrastructure to be ready..."
echo -e "${YELLOW}  Waiting for PostgreSQL...${NC}"
kubectl wait --for=condition=ready pod -l app=plane-db -n plane --timeout=120s
echo -e "${GREEN}  PostgreSQL ready${NC}"

echo -e "${YELLOW}  Waiting for Redis...${NC}"
kubectl wait --for=condition=ready pod -l app=plane-redis -n plane --timeout=120s
echo -e "${GREEN}  Redis ready${NC}"

echo -e "${YELLOW}  Waiting for RabbitMQ...${NC}"
kubectl wait --for=condition=ready pod -l app=plane-mq -n plane --timeout=120s
echo -e "${GREEN}  RabbitMQ ready${NC}"

echo -e "${YELLOW}  Waiting for MinIO...${NC}"
kubectl wait --for=condition=ready pod -l app=plane-minio -n plane --timeout=120s
echo -e "${GREEN}  MinIO ready${NC}"
echo ""

echo "Step 5: Running database migrations..."
kubectl apply -f migrator.yaml
echo -e "${YELLOW}  Waiting for migrations to complete...${NC}"
kubectl wait --for=condition=complete job/migrator -n plane --timeout=180s
echo -e "${GREEN}  Migrations complete${NC}"
echo ""

echo "Step 6: Deploying backend services..."
kubectl apply -f api.yaml
kubectl apply -f worker.yaml
kubectl apply -f beat-worker.yaml
echo -e "${GREEN}Backend services started${NC}"
echo ""

echo "Step 7: Waiting for API to be ready..."
kubectl wait --for=condition=ready pod -l app=api -n plane --timeout=120s
echo -e "${GREEN}  API ready${NC}"
echo ""

echo "Step 8: Deploying frontend services..."
kubectl apply -f web.yaml
kubectl apply -f space.yaml
kubectl apply -f admin.yaml
kubectl apply -f live.yaml
echo -e "${GREEN}Frontend services started${NC}"
echo ""

echo "Step 9: Waiting for frontend services..."
kubectl wait --for=condition=ready pod -l app=web -n plane --timeout=120s
echo -e "${GREEN}  Web ready${NC}"

echo -e "${YELLOW}  Waiting for Space...${NC}"
kubectl wait --for=condition=ready pod -l app=space -n plane --timeout=120s
echo -e "${GREEN}  Space ready${NC}"

echo -e "${YELLOW}  Waiting for Admin...${NC}"
kubectl wait --for=condition=ready pod -l app=admin -n plane --timeout=120s
echo -e "${GREEN}  Admin ready${NC}"

echo -e "${YELLOW}  Waiting for Live...${NC}"
kubectl wait --for=condition=ready pod -l app=live -n plane --timeout=120s
echo -e "${GREEN}  Live ready${NC}"
echo ""

echo "Step 10: Deploying proxy..."
kubectl apply -f proxy.yaml
echo -e "${GREEN}Proxy created${NC}"
echo ""

echo "Step 11: Waiting for proxy..."
kubectl wait --for=condition=ready pod -l app=proxy -n plane --timeout=120s
echo -e "${GREEN}  Proxy ready${NC}"
echo ""

echo "==================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "==================================="
echo ""
echo "Plane is available at:"
echo "  http://localhost:30080"
echo ""
echo "Or via port-forward:"
echo "  kubectl port-forward -n plane svc/proxy 8080:80"
echo "  http://localhost:8080"
echo ""
echo "RabbitMQ Management:"
echo "  kubectl port-forward -n plane svc/plane-mq 15672:15672"
echo "  http://localhost:15672 (login: plane/plane)"
echo ""
echo "MinIO Console:"
echo "  kubectl port-forward -n plane svc/plane-minio 9090:9090"
echo "  http://localhost:9090"
echo ""
echo "Useful commands:"
echo "  kubectl get pods -n plane"
echo "  kubectl logs -n plane deployment/api"
echo "  kubectl get svc -n plane"
