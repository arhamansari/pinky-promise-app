# Pinky Promise App - Phase 1 Infrastructure

This directory contains the Terraform configuration for deploying the Phase 1 infrastructure foundation for the Pinky Promise application on Google Cloud Platform using GKE Autopilot.

## 🏗️ Architecture Overview

The infrastructure includes:

- **GKE Autopilot Cluster**: Fully managed Kubernetes cluster
- **VPC Network**: Custom VPC with public, private, and database subnets
- **Cloud SQL**: PostgreSQL database with high availability and read replica
- **Secret Manager**: Centralized secret storage
- **IAM & Security**: Service accounts and Workload Identity
- **Monitoring**: Cloud Monitoring with dashboards and alerts

## 📋 Prerequisites

1. **Google Cloud Account** with billing enabled
2. **Google Cloud Project** created
3. **gcloud CLI** installed and configured
4. **Terraform** (>= 1.0) installed
5. **kubectl** installed

## 🚀 Quick Deployment

### 1. Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your project details
vim terraform.tfvars
```

Update the following required variables:
- `project_id`: Your GCP project ID
- `region`: Your preferred GCP region
- `alert_email`: Email for monitoring alerts (in modules/monitoring/variables.tf)

### 2. Deploy Infrastructure

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

The script will:
1. ✅ Check prerequisites
2. 🔐 Verify authentication
3. 🔧 Enable required APIs
4. 🏗️ Deploy infrastructure with Terraform
5. ⚙️ Configure kubectl
6. ✅ Verify deployment

### 3. Manual Deployment (Alternative)

If you prefer manual deployment:

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Configure kubectl
gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
  --region $(terraform output -raw region) \
  --project $(terraform output -raw project_id)
```

## 📊 Post-Deployment

### Verify Deployment

```bash
# Check cluster status
kubectl cluster-info

# View nodes
kubectl get nodes

# List namespaces
kubectl get namespaces

# View all terraform outputs
terraform output
```

### Access Monitoring

```bash
# Get monitoring dashboard URL
terraform output monitoring_dashboard_url
```

### Check Secrets

```bash
# List created secrets
gcloud secrets list --filter="labels.environment=production"
```

## 🔧 Configuration Details

### Network Configuration

- **VPC CIDR**: 10.0.0.0/16
- **Public Subnet**: 10.0.1.0/24 (Load balancer, NAT)
- **Private Subnet**: 10.0.2.0/24 (GKE nodes)
- **Database Subnet**: 10.0.3.0/24 (Cloud SQL)
- **Pod CIDR**: 10.1.0.0/16
- **Service CIDR**: 10.2.0.0/16

### Security Features

- ✅ Private GKE nodes
- ✅ Workload Identity enabled
- ✅ Network policies enabled
- ✅ Secret Manager integration
- ✅ Private Cloud SQL
- ✅ SSL/TLS encryption

### Database Configuration

- **Engine**: PostgreSQL 14
- **Tier**: db-custom-2-4096 (2 vCPU, 4GB RAM)
- **High Availability**: Regional
- **Backups**: Daily with 30-day retention
- **Read Replica**: Enabled

## 🗂️ Module Structure

```
terraform/
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (create from .example)
└── modules/
    ├── networking/         # VPC, subnets, firewall
    ├── gke-cluster/        # GKE Autopilot cluster
    ├── database/           # Cloud SQL PostgreSQL
    ├── security/           # IAM, secrets, service accounts
    └── monitoring/         # Monitoring and alerting
```

## 🔍 Troubleshooting

### Common Issues

1. **API Not Enabled**
   ```bash
   # Enable required APIs
   gcloud services enable container.googleapis.com compute.googleapis.com
   ```

2. **Insufficient Permissions**
   ```bash
   # Check your permissions
   gcloud projects get-iam-policy YOUR_PROJECT_ID
   ```

3. **Quota Exceeded**
   ```bash
   # Check quotas
   gcloud compute project-info describe --project=YOUR_PROJECT_ID
   ```

4. **kubectl Access Issues**
   ```bash
   # Re-configure kubectl
   gcloud container clusters get-credentials CLUSTER_NAME --region REGION
   ```

### Debug Commands

```bash
# View terraform state
terraform state list

# Check specific resource
terraform state show google_container_cluster.primary

# View logs
kubectl logs -n kube-system -l k8s-app=metrics-server

# Check cluster events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

## 💰 Cost Optimization

- **GKE Autopilot**: Pay only for running pods
- **Cloud SQL**: Consider smaller tiers for dev/staging
- **Persistent Disks**: Use standard disks for non-critical data
- **Regional vs Zonal**: Use zonal for cost savings in non-prod

## 🔄 Next Steps (Phase 2)

After Phase 1 completion:

1. **Application Deployment**: Deploy your Node.js and React applications
2. **Ingress Setup**: Configure NGINX Ingress and SSL certificates
3. **CI/CD Pipeline**: Set up GitHub Actions for automated deployments
4. **Helm Charts**: Package applications for easier management

## 📚 Additional Resources

- [GKE Autopilot Documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Terraform and kubectl logs
3. Verify GCP quotas and permissions
4. Consult Google Cloud documentation

---

**Note**: This infrastructure is configured for production use. For development/testing, consider reducing resource sizes and disabling high availability features to save costs.

