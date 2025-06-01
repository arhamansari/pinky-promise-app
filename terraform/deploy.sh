#!/bin/bash

# Pinky Promise App - Phase 1 Infrastructure Deployment Script
# This script deploys the GKE infrastructure foundation

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    # Check for gcloud
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed. Please install it from https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check for terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it from https://www.terraform.io/downloads.html"
        exit 1
    fi
    
    # Check for kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it from https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    
    print_success "All requirements are met"
}

# Check if user is authenticated with gcloud
check_auth() {
    print_status "Checking Google Cloud authentication..."
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "Not authenticated with Google Cloud. Please run 'gcloud auth login'"
        exit 1
    fi
    
    print_success "Google Cloud authentication verified"
}

# Validate terraform.tfvars exists
check_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars file not found!"
        print_status "Please copy terraform.tfvars.example to terraform.tfvars and update with your values:"
        echo "cp terraform.tfvars.example terraform.tfvars"
        exit 1
    fi
    
    # Check if project_id is set
    if grep -q "your-gcp-project-id" terraform.tfvars; then
        print_error "Please update the project_id in terraform.tfvars with your actual GCP project ID"
        exit 1
    fi
    
    print_success "terraform.tfvars file found and configured"
}

# Enable required Google Cloud APIs
enable_apis() {
    print_status "Enabling required Google Cloud APIs..."
    
    PROJECT_ID=$(grep '^project_id' terraform.tfvars | cut -d'"' -f2)
    
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "your-gcp-project-id" ]; then
        print_error "Invalid project_id in terraform.tfvars"
        exit 1
    fi
    
    gcloud config set project $PROJECT_ID
    
    # Enable APIs
    gcloud services enable compute.googleapis.com \
        container.googleapis.com \
        sqladmin.googleapis.com \
        servicenetworking.googleapis.com \
        secretmanager.googleapis.com \
        iam.googleapis.com \
        monitoring.googleapis.com \
        logging.googleapis.com \
        cloudresourcemanager.googleapis.com
    
    print_success "APIs enabled successfully"
}

# Run terraform deployment
deploy_infrastructure() {
    print_status "Initializing Terraform..."
    terraform init
    
    print_status "Validating Terraform configuration..."
    terraform validate
    
    print_status "Planning Terraform deployment..."
    terraform plan -out=tfplan
    
    echo
    print_warning "Review the plan above. This will create infrastructure in your GCP project."
    read -p "Do you want to proceed with the deployment? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Deployment cancelled by user"
        exit 0
    fi
    
    print_status "Applying Terraform configuration..."
    terraform apply tfplan
    
    print_success "Infrastructure deployment completed!"
}

# Configure kubectl
configure_kubectl() {
    print_status "Configuring kubectl..."
    
    PROJECT_ID=$(grep '^project_id' terraform.tfvars | cut -d'"' -f2)
    REGION=$(grep '^region' terraform.tfvars | cut -d'"' -f2 || echo "us-central1")
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    
    gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID
    
    print_success "kubectl configured successfully"
}

# Verify deployment
verify_deployment() {
    print_status "Verifying deployment..."
    
    # Check cluster status
    if kubectl cluster-info >/dev/null 2>&1; then
        print_success "GKE cluster is accessible"
    else
        print_error "Cannot access GKE cluster"
        return 1
    fi
    
    # Check namespaces
    print_status "Checking created namespaces..."
    kubectl get namespaces
    
    # Check nodes
    print_status "Checking cluster nodes..."
    kubectl get nodes
    
    print_success "Deployment verification completed"
}

# Display post-deployment information
show_info() {
    echo
    print_success "🎉 Phase 1 Infrastructure Deployment Completed!"
    echo
    print_status "Infrastructure Details:"
    echo "  • Cluster Name: $(terraform output -raw cluster_name)"
    echo "  • Cluster Location: $(terraform output -raw cluster_location)"
    echo "  • VPC Name: $(terraform output -raw vpc_name)"
    echo "  • Database Host: $(terraform output -raw database_private_ip)"
    echo
    print_status "Next Steps:"
    echo "  1. Review the monitoring dashboard: $(terraform output -raw monitoring_dashboard_url)"
    echo "  2. Configure your application secrets in Secret Manager"
    echo "  3. Proceed to Phase 2: Application Deployment"
    echo
    print_status "Useful Commands:"
    echo "  • View cluster info: kubectl cluster-info"
    echo "  • List namespaces: kubectl get namespaces"
    echo "  • View terraform outputs: terraform output"
    echo "  • Connect to cluster: $(terraform output -raw kubectl_config_command)"
    echo
}

# Main execution
main() {
    echo "=================================================="
    echo "  Pinky Promise App - Phase 1 Infrastructure    "
    echo "  GKE Autopilot Cluster Deployment              "
    echo "=================================================="
    echo
    
    check_requirements
    check_auth
    check_tfvars
    enable_apis
    deploy_infrastructure
    configure_kubectl
    verify_deployment
    show_info
}

# Run main function
main "$@"

