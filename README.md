# Kubernetes Deployments

Self-hosted applications on k3s.

## Repository Structure

```
.
├── rocketchat/          # Team chat application with MongoDB
├── infisical/           # Secret management with PostgreSQL and Redis
└── plane/               # Project management with PostgreSQL, Redis, RabbitMQ, and MinIO
```

## Application Details

### rocketchat/
Contains Kubernetes manifests for deploying RocketChat (team chat platform) with MongoDB database and replica set configuration.

### infisical/
Contains manifests for Infisical secret management platform with PostgreSQL database, Redis cache, and Let's Encrypt SSL certificate configuration.

### plane/
Contains manifests for Plane project management tool with PostgreSQL database, Redis, RabbitMQ message broker, and MinIO object storage.

---

**Prerequisites:** k3s cluster, kubectl, cert-manager, ingress-nginx
