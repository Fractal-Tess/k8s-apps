# ☸️ Kubernetes Deployments

A collection of Kubernetes manifests for self-hosted applications on k3s.

## 📦 Included Applications

| Application | Description | Namespace |
|------------|-------------|-----------|
| 🚀 **RocketChat** | Open-source team chat | `rocketchat` |
| 🔐 **Infisical** | Secret management platform | `infisical` |
| ✈️ **Plane** | Open-source project management | `plane` |

## 🚀 Quick Start

Each application has its own directory with a simple deployment script:

```bash
cd <application-name>
./deploy.sh
```

## 📁 Repository Structure

```
.
├── rocketchat/          # RocketChat + MongoDB
├── infisical/           # Infisical + PostgreSQL + Redis
└── plane/               # Plane + PostgreSQL + Redis + RabbitMQ + MinIO
```

## ⚙️ Pre-Deployment

Before deploying, update the secrets in each `secrets.yaml`:

```bash
# Edit secrets
vim <app>/secrets.yaml

# Look for placeholders like:
# <CHANGE_ME_*>
# And replace with actual values
```

## 🏗️ Prerequisites

- k3s cluster running
- kubectl configured
- cert-manager (for Infisical SSL)
- ingress-nginx

## 📖 Application Details

### RocketChat
Team communication platform with MongoDB replica set.

### Infisical
Secret management with HTTPS via Let's Encrypt.

### Plane
Project management tool with full backend stack.

---

💡 **Tip**: Check each application's README for specific configuration options.
