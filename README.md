# Pinky Promise Infrastructure & GitOps

This repository contains the infrastructure-as-code and GitOps configuration for the Pinky Promise application.

## 🏗️ Architecture Overview

### Repository Strategy
- **Infrastructure Repository (this repo)**: Contains Terraform for GCP infrastructure, Kubernetes base manifests, and ArgoCD configuration
- **Application Repository**: Contains application source code and application-specific Kubernetes manifests

### Infrastructure Components
- **GKE Cluster**: Google Kubernetes Engine cluster with autoscaling
- **Cloud SQL**: PostgreSQL database with backup and high availability
- **VPC Network**: Custom VPC with public/private subnets
- **ArgoCD**: GitOps tool for continuous deployment
- **Monitoring**: Google Cloud Monitoring and Alerting

## 🚀 Quick Start

### Prerequisites

1. **Google Cloud Project**: Set up a GCP project
2. **Service Account**: Create a service account with necessary permissions
3. **Terraform State Bucket**: Create a GCS bucket for Terraform state
4. **GitHub Secrets**: Configure repository secrets

### Step 1: GCP Setup

```bash
# 1. Create a new GCP project or use existing
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# 2. Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# 3. Create a service account for GitHub Actions
gcloud iam service-accounts create github-actions \
    --description="Service account for GitHub Actions" \
    --display-name="GitHub Actions"

# 4. Grant necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/container.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

# 5. Create and download service account key
gcloud iam service-accounts keys create github-actions-key.json \
    --iam-account=github-actions@$PROJECT_ID.iam.gserviceaccount.com

# 6. Create Terraform state bucket
gsutil mb gs://$PROJECT_ID-terraform-state
gsutil versioning set on gs://$PROJECT_ID-terraform-state
```

### Step 2: GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `GCP_SA_KEY` | Service account JSON key | Contents of `github-actions-key.json` |
| `TF_STATE_BUCKET` | Terraform state bucket | `your-project-id-terraform-state` |

### Step 3: Update Configuration

1. **Update Terraform variables** in `terraform/terraform.tfvars`:
```hcl
project_id = "your-project-id"
environment = "production"
alert_email = "your-email@example.com"
```

2. **Update ArgoCD Application** in `kubernetes/argocd/pinky-promise-app.yaml`:
```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/pinky-promise-app-source
```

3. **Update project ID** in `.github/workflows/infrastructure.yml`:
```yaml
env:
  PROJECT_ID: 'your-project-id'
```

## 🔄 CI/CD Pipeline

### Infrastructure Pipeline

**Non-main branches:**
- ✅ Terraform Format Check
- ✅ Terraform Validate
- ✅ Terraform Plan
- ✅ Security Scan

**Main branch (additional steps):**
- ✅ Terraform Apply
- ✅ ArgoCD Installation
- ✅ ArgoCD Configuration

### Application Pipeline (in separate repo)

- ✅ Build and Test
- ✅ Build Docker Images
- ✅ Push to Artifact Registry
- ✅ Update Kubernetes Manifests
- ✅ ArgoCD Auto-Deploy

## 📁 Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── infrastructure.yml      # Infrastructure CI/CD pipeline
├── terraform/
│   ├── main.tf                     # Main Terraform configuration
│   ├── variables.tf                # Variable definitions
│   ├── outputs.tf                  # Output definitions
│   ├── terraform.tfvars.example    # Example variables
│   └── modules/
│       ├── networking/             # VPC and networking
│       ├── gke-cluster/           # GKE cluster configuration
│       ├── database/              # Cloud SQL configuration
│       ├── security/              # IAM and security
│       └── monitoring/            # Monitoring and alerting
└── kubernetes/
    ├── argocd/
    │   ├── pinky-promise-project.yaml  # ArgoCD project
    │   └── pinky-promise-app.yaml      # ArgoCD application
    └── manifests/                       # Base Kubernetes manifests
```

## 🔧 Manual Operations

### Deploy Infrastructure

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/pinky-promise-infrastructure
cd pinky-promise-infrastructure

# Initialize Terraform
cd terraform
terraform init \
  -backend-config="bucket=your-project-id-terraform-state" \
  -backend-config="prefix=terraform/state"

# Plan the deployment
terraform plan -var-file="terraform.tfvars"

# Apply the configuration
terraform apply -var-file="terraform.tfvars"
```

### Access ArgoCD UI

```bash
# Get cluster credentials
gcloud container clusters get-credentials pinky-promise-cluster \
  --zone us-central1-a --project your-project-id

# Port forward to ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD at https://localhost:8080
# Username: admin
# Password: (from above command)
```

### Monitor Applications

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check application pods
kubectl get pods -n pinky-promise

# Check application logs
kubectl logs -f deployment/pinky-promise-backend -n pinky-promise
kubectl logs -f deployment/pinky-promise-frontend -n pinky-promise
```

## 🔒 Security Considerations

- **Service Account Permissions**: Use principle of least privilege
- **Secrets Management**: Store sensitive data in Google Secret Manager
- **Network Security**: Private GKE nodes with authorized networks
- **Image Security**: Regular vulnerability scanning with Trivy
- **RBAC**: Proper Kubernetes role-based access control

## 📊 Monitoring & Alerting

- **Google Cloud Monitoring**: Infrastructure and application metrics
- **Uptime Checks**: Application availability monitoring
- **Log Aggregation**: Centralized logging with Google Cloud Logging
- **Alerting**: Email and Slack notifications for critical issues

## 🚨 Troubleshooting

### Common Issues

1. **Terraform Apply Fails**
   - Check service account permissions
   - Verify API enablement
   - Check quota limits

2. **ArgoCD Sync Issues**
   - Verify repository access
   - Check application configuration
   - Review ArgoCD logs

3. **Application Deployment Issues**
   - Check image registry access
   - Verify Kubernetes resource limits
   - Review pod logs

### Support

For issues and questions:
1. Check the troubleshooting section
2. Review GitHub Actions logs
3. Check ArgoCD application status
4. Review Google Cloud Console for infrastructure issues

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test locally if possible
4. Create a pull request
5. Review CI/CD pipeline results
6. Merge to main after approval

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

# 🎯 Pinky Promise App

A production-ready full-stack web application with React frontend, Node.js backend, and PostgreSQL database, deployed on Google Cloud Platform with Kubernetes.

## 🏗️ Architecture

- **Frontend**: React application with modern UI/UX
- **Backend**: Node.js/Express RESTful API
- **Database**: PostgreSQL with read replicas
- **Infrastructure**: Google Cloud Platform (GKE, Cloud SQL, VPC)
- **Deployment**: Kubernetes with auto-scaling
- **Monitoring**: Real-time dashboards and alerting
- **Security**: Workload Identity, Secret Manager, private networking

## 📁 Project Structure

```
pinky-promise-app/
├── pinky-promise-app/    # React frontend application
├── backend/              # Node.js backend API
├── terraform/            # Infrastructure as Code (GCP)
├── kubernetes/           # Kubernetes manifests
├── deploy/               # Deployment configurations
├── docs/                 # Documentation
│   ├── architecture/     # Architecture documentation
│   ├── deployment/       # Deployment guides
│   └── development/      # Development setup
└── .github/              # CI/CD workflows
```

## 🎯 Current Status

**✅ Phase 1 Complete**: Infrastructure Foundation
- GKE Autopilot cluster deployed
- Cloud SQL PostgreSQL with read replica
- VPC with secure networking
- Secret Manager integration
- Monitoring and alerting setup
- Path-based CI/CD pipeline

**🚀 Ready for Phase 2**: Application Deployment

## 📋 Prerequisites

Before running this application, ensure you have the following installed on your local machine:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)
- **Git**: [Install Git](https://git-scm.com/downloads)

### Verify Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Ensure Docker is running
docker ps
```

## 🚀 Quick Start

### Option 1: Using Helper Scripts (Recommended)

```bash
git clone <repository-url>
cd pinky-promise-app
git checkout -b localdeployment origin/localdeployment

# Start the application (this handles everything automatically)
./start.sh

# Stop the application when done
./stop.sh
```

#### What the start script does:
1. ✅ Checks if Docker is running
2. 📝 Creates `.env` file from template (if it doesn't exist)
3. 🛑 Stops any existing containers
4. 🏗️ Builds and starts all services (database, backend, frontend)
5. ⏳ Waits for database to be ready
6. 🗃️ Initializes database schema automatically
7. 🎉 Shows success message with access URLs

#### Expected output when running `./start.sh`:
```
🚀 Starting Pinky Promise App...
==================================================
✅ Docker is running
📝 Creating environment file...
✅ Environment file created at deploy/.env
⚠️  Please edit deploy/.env with your configuration before production use!
🛑 Stopping existing containers...
🏗️  Building and starting services...
[Docker build output...]
⏳ Waiting for database to be ready...
🗃️  Initializing database schema...
CREATE EXTENSION
CREATE TABLE
==================================================
🎉 Application is now running!

📱 Frontend: http://localhost:80
🔧 Backend API: http://localhost:5001
🗄️  Database: localhost:5432

📊 Check status: docker-compose -f deploy/docker-compose.yml ps
📋 View logs: docker-compose -f deploy/docker-compose.yml logs -f
🛑 Stop app: docker-compose -f deploy/docker-compose.yml down
==================================================
```

### Option 2: Manual Setup

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd pinky-promise-app
```

### 2. Environment Configuration

Create environment file for deployment:

```bash
cp deploy/.env.example deploy/.env
```

Edit `deploy/.env` with your configuration:

```env
# Database Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=pinky_promise

# JWT Secrets (change these in production)
JWT_SECRET=your-jwt-secret-key
JWT_REFRESH_SECRET=your-jwt-refresh-secret-key

# ReCAPTCHA (optional)
RECAPTCHA_SECRET_KEY=your-recaptcha-secret
```

### 3. Build and Run

```bash
# Build and start all services
docker-compose -f deploy/docker-compose.yml up --build -d

# View logs (optional)
docker-compose -f deploy/docker-compose.yml logs -f
```

### 4. Initialize Database

Apply the database schema:

```bash
docker exec -i pinky-promise-db psql -U postgres -d pinky_promise < backend/schema.sql
```

### 5. Access the Application

- **Frontend**: [http://localhost](http://localhost)
- **Backend API**: [http://localhost:5001](http://localhost:5001)
- **Database**: `localhost:5432`

## 📁 Project Structure

```
pinky-promise-app/
├── README.md                    # This file
├── backend/                     # Node.js API server
│   ├── server.js               # Main server file
│   ├── package.json            # Backend dependencies
│   ├── schema.sql              # Database schema
│   ├── routes/                 # API routes
│   └── middleware/             # Express middleware
├── pinky-promise-app/          # React frontend
│   ├── src/                    # React source code
│   ├── public/                 # Static assets
│   └── package.json            # Frontend dependencies
└── deploy/                     # Docker deployment
    ├── docker-compose.yml      # Service orchestration
    ├── .env                    # Environment variables
    ├── backend/
    │   └── Dockerfile          # Backend container config
    └── frontend/
        ├── Dockerfile          # Frontend container config
        └── nginx.conf          # Nginx configuration
```

## 🐳 Docker Services

### Database (PostgreSQL)
- **Container**: `pinky-promise-db`
- **Port**: `5432`
- **Image**: `postgres:14-alpine`
- **Volume**: `postgres_data` (persistent storage)

### Backend (Node.js API)
- **Container**: `pinky-promise-backend`
- **Port**: `5001`
- **Build Context**: `backend/`
- **Health Check**: HTTP check on `/`

### Frontend (React + Nginx)
- **Container**: `pinky-promise-frontend`
- **Port**: `80`
- **Build Context**: `pinky-promise-app/`
- **Multi-stage**: Build with Node.js, serve with Nginx

## 🎯 Script Execution Guide

### Running the Start Script

Make the script executable (if needed):
```bash
chmod +x start.sh
```

Execute the start script:
```bash
./start.sh
```

### Verifying the Application is Running

After running `./start.sh`, verify everything is working:

#### 1. Check Container Status
```bash
docker-compose -f deploy/docker-compose.yml ps
```

**Expected output:**
```
NAME                     IMAGE                COMMAND                  SERVICE    CREATED        STATUS                 PORTS
pinky-promise-backend    deploy-backend       "docker-entrypoint.s…"   backend    2 minutes ago  Up 2 minutes (healthy) 0.0.0.0:5001->5001/tcp
pinky-promise-db         postgres:14-alpine   "docker-entrypoint.s…"   db         2 minutes ago  Up 2 minutes (healthy) 0.0.0.0:5432->5432/tcp
pinky-promise-frontend   deploy-frontend      "/docker-entrypoint.…"   frontend   2 minutes ago  Up 2 minutes           0.0.0.0:80->80/tcp
```

#### 2. Test Database Connection
```bash
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "\dt"
```

**Expected output:**
```
         List of relations
 Schema | Name  | Type  |  Owner   
--------+-------+-------+----------
 public | users | table | postgres
(1 row)
```

#### 3. Test Backend API
```bash
curl http://localhost:5001
```

**Expected output:** Should return a response from your API (varies based on implementation)

#### 4. Test Frontend
```bash
curl -I http://localhost
```

**Expected output:**
```
HTTP/1.1 200 OK
Server: nginx/1.24.0
Content-Type: text/html
...
```

#### 5. Test Database Query
```bash
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "SELECT COUNT(*) FROM users;"
```

**Expected output:**
```
 count 
-------
     0
(1 row)
```

### Running the Stop Script

To stop all services:
```bash
./stop.sh
```

**Expected output:**
```
🛑 Stopping Pinky Promise App...
========================================
[+] Running 4/4
 ✔ Container pinky-promise-frontend  Removed
 ✔ Container pinky-promise-backend   Removed
 ✔ Container pinky-promise-db        Removed
 ✔ Network deploy_app-network        Removed
✅ All containers stopped
📊 To check status: docker-compose -f deploy/docker-compose.yml ps
🗑️  To remove volumes (delete data): docker-compose -f deploy/docker-compose.yml down --volumes
========================================
```

### Verifying Stop

Check that all containers are stopped:
```bash
docker-compose -f deploy/docker-compose.yml ps
```

**Expected output:** Should show no running containers or empty output.

### Accessing the Application

Once the start script completes successfully, you can access:

- **Frontend Application**: Open [http://localhost](http://localhost) in your web browser
- **Backend API**: Test API endpoints at [http://localhost:5001](http://localhost:5001)
- **Database**: Connect using any PostgreSQL client to `localhost:5432`

### 📋 Quick Verification Checklist

After running `./start.sh`, use this checklist to ensure everything is working:

- [ ] **Containers Running**: `docker-compose -f deploy/docker-compose.yml ps` shows all 3 services as "Up"
- [ ] **Database Ready**: `docker exec pinky-promise-db pg_isready -U postgres` returns "accepting connections"
- [ ] **Schema Applied**: `docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "\dt"` shows "users" table
- [ ] **Frontend Accessible**: Browser opens [http://localhost](http://localhost) successfully
- [ ] **Backend Responsive**: `curl http://localhost:5001` returns a response
- [ ] **Database Queryable**: `docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "SELECT COUNT(*) FROM users;"` works

If all items are checked ✅, your application is ready to use!

### Common Script Errors and Solutions

**Error: `Docker is not running`**
```bash
❌ Error: Docker is not running. Please start Docker and try again.
```
**Solution:** Start Docker Desktop and wait for it to be fully loaded.

**Error: `Permission denied`**
```bash
./start.sh: Permission denied
```
**Solution:** Make the script executable:
```bash
chmod +x start.sh stop.sh
```

**Error: `Port already in use`**
```bash
Error response from daemon: driver failed programming external connectivity
```
**Solution:** Stop any services using ports 80, 5001, or 5432:
```bash
# Find what's using the ports
lsof -i :80 -i :5001 -i :5432

# Kill the processes or stop other Docker containers
docker stop $(docker ps -q)
```

## 🛠️ Development Commands

### Managing Services

```bash
# Start services
docker-compose -f deploy/docker-compose.yml up -d

# Stop services
docker-compose -f deploy/docker-compose.yml down

# Stop and remove volumes (⚠️ deletes database data)
docker-compose -f deploy/docker-compose.yml down --volumes

# View service status
docker-compose -f deploy/docker-compose.yml ps

# View logs
docker-compose -f deploy/docker-compose.yml logs [service-name]

# Rebuild specific service
docker-compose -f deploy/docker-compose.yml up --build [service-name]
```

### Database Operations

```bash
# Connect to database
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise

# Run SQL commands
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "SELECT * FROM users;"

# Backup database
docker exec pinky-promise-db pg_dump -U postgres pinky_promise > backup.sql

# Restore database
docker exec -i pinky-promise-db psql -U postgres -d pinky_promise < backup.sql
```

### Useful SQL Commands

```sql
-- List all tables
\dt

-- Describe users table
\d users

-- View all users
SELECT id, name, email, created_at FROM users ORDER BY created_at DESC;

-- Count total users
SELECT COUNT(*) FROM users;

-- Exit psql
\q
```

## 🔧 Troubleshooting

### Common Issues

**1. Port Already in Use**
```bash
# Check what's using the port
lsof -i :80
lsof -i :5001
lsof -i :5432

# Kill process using port (replace PID)
kill -9 <PID>
```

**2. Database Connection Issues**
```bash
# Check if database is healthy
docker-compose -f deploy/docker-compose.yml ps

# View database logs
docker-compose -f deploy/docker-compose.yml logs db

# Restart database service
docker-compose -f deploy/docker-compose.yml restart db
```

**3. Build Failures**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose -f deploy/docker-compose.yml build --no-cache
```

**4. Permission Issues (macOS/Linux)**
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

### Health Checks

```bash
# Check all services are running
docker-compose -f deploy/docker-compose.yml ps

# Test backend API
curl http://localhost:5001

# Test frontend
curl http://localhost

# Test database connection
docker exec pinky-promise-db pg_isready -U postgres
```

## 🔐 Security Notes

- **Default passwords**: Change default database passwords in production
- **JWT secrets**: Use strong, unique secrets for JWT tokens
- **Environment variables**: Never commit `.env` files with real secrets
- **Database access**: Database is only accessible from Docker network by default

## 📝 API Endpoints

Once running, the backend API will be available at `http://localhost:5001` with endpoints like:

- `GET /api/users` - Get all users
- `POST /api/users` - Create new user
- `GET /api/users/:id` - Get specific user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

*(Actual endpoints may vary based on your implementation)*

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [React Documentation](https://reactjs.org/docs/)
- [Node.js Documentation](https://nodejs.org/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker
5. Submit a pull request

## 📄 License

[Add your license information here]

---

**Note**: This application is configured for development use. For production deployment, additional security measures, environment configurations, and performance optimizations should be implemented.

