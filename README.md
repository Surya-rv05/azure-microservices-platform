# ☸️ Azure Microservices Platform — Project 2

> Production-grade microservices platform on Azure Kubernetes Service with Infrastructure as Code, Helm-based deployments, and full GitOps via ArgoCD.

---

## 🏗️ Architecture

```
                        Internet
                            │
                            ▼
                 ┌────────────────────┐
                 │  Azure Load        │
                 │  Balancer (public) │
                 └────────────────────┘
                            │
                            ▼
        ┌─────────────────────────────────────┐
        │   AKS Cluster (Central India)       │
        │                                     │
        │   ┌──────────────────────────────┐  │
        │   │    API Gateway (3 pods)      │  │
        │   │    LoadBalancer Service      │  │
        │   └──────────────────────────────┘  │
        │           │              │          │
        │           ▼              ▼          │
        │   ┌──────────┐    ┌────────────┐    │
        │   │   Auth   │    │  Product   │    │
        │   │ (2 pods) │    │  (2 pods)  │    │
        │   │ ClusterIP│    │ ClusterIP  │    │
        │   └──────────┘    └────────────┘    │
        │                                     │
        └─────────────────────────────────────┘
                            ▲
                            │
                  Auto-sync via GitOps
                            │
                 ┌──────────────────────┐
                 │       ArgoCD         │
                 │  (running in AKS)    │
                 └──────────────────────┘
                            ▲
                            │
                       Watches repo
                            │
                 ┌──────────────────────┐
                 │   GitHub Repo        │
                 │  (Source of Truth)   │
                 └──────────────────────┘
```

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| **Cloud** | Microsoft Azure |
| **IaC** | Terraform (with Azure Blob backend) |
| **Containers** | Docker |
| **Container Registry** | Azure Container Registry (ACR) |
| **Orchestration** | Azure Kubernetes Service (AKS) |
| **Package Manager** | Helm |
| **GitOps** | ArgoCD |
| **Secrets** | Azure Key Vault |
| **Language** | Python (Flask) |
| **Source Control** | Git + GitHub |

---

## 🎯 What This Project Demonstrates

- ✅ **Infrastructure as Code** — Full Azure infrastructure provisioned via Terraform
- ✅ **Remote State Management** — Terraform state in Azure Blob Storage
- ✅ **Containerization** — 3 Python microservices Dockerized with security best practices
- ✅ **Private Container Registry** — Images stored in ACR with RBAC
- ✅ **Kubernetes Orchestration** — Multi-replica deployments on AKS
- ✅ **Service Mesh Concepts** — Internal service discovery via ClusterIP
- ✅ **Load Balancing** — Public LoadBalancer for external traffic
- ✅ **Health Checks** — Liveness and readiness probes
- ✅ **Resource Limits** — CPU/memory requests and limits
- ✅ **Helm Packaging** — One chart, multiple services via values files
- ✅ **GitOps** — Automated deployments via ArgoCD
- ✅ **Security** — Managed identities, non-root containers, HTTPS

---

## 📁 Project Structure

```
project2-microservices/
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Azure resources
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   ├── providers.tf        # Azure provider + backend
│   └── terraform.tfvars    # Variable values
│
├── services/               # 3 microservices
│   ├── api-gateway/        # Entry point service (port 5000)
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── auth-service/       # Authentication (port 5001)
│   └── product-service/    # Product catalog (port 5002)
│
├── kubernetes/             # Raw Kubernetes manifests (learning)
│
├── helm/                   # Helm charts
│   ├── microservice/       # Generic chart for any microservice
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   ├── values-api-gateway.yaml
│   ├── values-auth-service.yaml
│   └── values-product-service.yaml
│
└── README.md
```

---

## 🚀 Microservices Overview

### API Gateway (Port 5000)
- **Type:** LoadBalancer (public)
- **Replicas:** 3
- **Role:** Entry point — routes traffic to internal services

### Auth Service (Port 5001)
- **Type:** ClusterIP (internal only)
- **Replicas:** 2
- **Role:** Handles user authentication, returns tokens

### Product Service (Port 5002)
- **Type:** ClusterIP (internal only)
- **Replicas:** 2
- **Role:** Product catalog and inventory

---

## 🔄 GitOps Workflow

```
1. Developer pushes code to GitHub
2. ArgoCD (running inside AKS) polls the repo
3. Detects change in Helm chart or values files
4. Automatically applies changes to cluster
5. Self-heals if cluster state drifts from Git
```

**Zero manual kubectl commands in production.**

---

## 🏃 How to Deploy This Yourself

### Prerequisites
- Azure CLI
- Terraform
- Docker Desktop
- kubectl
- Helm
- Azure account with active subscription

### 1. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### 2. Connect to AKS

```bash
az aks get-credentials --resource-group rg-project2-dev --name aks-microservices-dev
```

### 3. Build and Push Docker Images

```bash
# Login to ACR
az acr login --name <acr-name>

# For each service
docker build -t <acr-name>.azurecr.io/<service>:v1 .
docker push <acr-name>.azurecr.io/<service>:v1
```

### 4. Deploy with Helm

```bash
cd helm
helm install api-gateway ./microservice -f values-api-gateway.yaml
helm install auth-service ./microservice -f values-auth-service.yaml
helm install product-service ./microservice -f values-product-service.yaml
```

### 5. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 6. Set Up GitOps
Create ArgoCD Applications pointing to this repo.

---

## 🔐 Security Highlights

- ✅ Non-root containers (security best practice)
- ✅ System-assigned managed identity for AKS
- ✅ RBAC between AKS and ACR (no hardcoded credentials)
- ✅ Azure Key Vault for secrets
- ✅ TLS 1.2 minimum
- ✅ Private ClusterIP for internal services
- ✅ Resource limits prevent resource exhaustion attacks
- ✅ Terraform state in private Azure Blob Storage

---

## 📊 Key Metrics

| Metric | Value |
|---|---|
| **Total Infrastructure Resources** | 7 (via Terraform) |
| **Microservices** | 3 |
| **Total Running Pods** | 7 (3 + 2 + 2) |
| **Kubernetes Objects** | 6 (3 deployments + 3 services) |
| **Time to Deploy from Scratch** | ~15 minutes |

---

## 📚 What I Learned

- Writing production-grade Terraform with remote state
- Dockerizing Python services with security best practices
- Kubernetes Deployments, Services, Pods, and namespaces
- Writing reusable Helm charts with values overrides
- Service discovery within Kubernetes clusters
- Installing and managing ArgoCD for GitOps
- Troubleshooting OneDrive + Helm compatibility issues
- PowerShell vs Bash differences for DevOps work

---

## 🗺️ Part of My Azure Learning Journey

| Project | Description | Status |
|---|---|---|
| 01 — Portfolio Site | Azure Blob Storage + Bicep + GitHub Actions | ✅ Complete |
| **02 — Microservices on AKS** | **Terraform + Docker + Kubernetes + Helm + ArgoCD** | **✅ Complete** |
| 03 — DevSecOps Pipeline | Trivy + tfsec + Gitleaks + Defender | 📅 Planned |
| 04 — Lakehouse Platform | Databricks + Delta Lake + Synapse + Power BI | 📅 Planned |

---

*Built with ❤️ on Microsoft Azure | Surya — Azure DevOps & Data Engineer*