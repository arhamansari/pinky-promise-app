# Pinky Promise App - Main Terraform Configuration
# Phase 1: Infrastructure Foundation

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }

  # Backend configuration for CI/CD
  backend "gcs" {
    # Bucket and prefix will be provided via backend-config in CI/CD
    # bucket = "your-terraform-state-bucket"  # Set via CI/CD
    # prefix = "terraform/state"              # Set via CI/CD
  }
}

# Provider configurations
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Data sources
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke_cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)
}

# Local values
locals {
  common_labels = {
    project     = "pinky-promise"
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  common_labels = local.common_labels

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
  pods_cidr            = var.pods_cidr
  services_cidr        = var.services_cidr
}

# Security Module
module "security" {
  source = "./modules/security"

  project_id             = var.project_id
  region                 = var.region
  environment            = var.environment
  common_labels          = local.common_labels
  workload_identity_pool = module.gke_cluster.workload_identity_pool

  depends_on = [module.networking, module.gke_cluster]
}

# GKE Cluster Module
module "gke_cluster" {
  source = "./modules/gke-cluster"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  common_labels = local.common_labels

  vpc_name            = module.networking.vpc_name
  subnet_name         = module.networking.private_subnet_name
  pods_range_name     = module.networking.pods_range_name
  services_range_name = module.networking.services_range_name

  cluster_name           = var.cluster_name
  enable_private_nodes   = var.enable_private_nodes
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  authorized_networks    = var.authorized_networks

  depends_on = [module.networking]
}

# Database Module
module "database" {
  source = "./modules/database"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  common_labels = local.common_labels

  vpc_name              = module.networking.vpc_self_link
  database_name         = var.database_name
  database_tier         = var.database_tier
  enable_read_replica   = var.enable_read_replica
  enable_backup         = var.enable_backup
  backup_retention_days = var.backup_retention_days

  depends_on = [module.networking]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  common_labels = local.common_labels

  cluster_name = module.gke_cluster.cluster_name
  alert_email  = var.alert_email

  depends_on = [module.gke_cluster]
}

