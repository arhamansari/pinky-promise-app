# GKE Cluster Module - Autopilot Cluster

# Enable required APIs
resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"
  
  disable_dependent_services = true
}

resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  
  disable_dependent_services = true
}

# GKE Autopilot Cluster
resource "google_container_cluster" "primary" {
  name     = "${var.environment}-${var.cluster_name}"
  location = var.region
  project  = var.project_id
  
  # Enable Autopilot
  enable_autopilot = true
  
  # Network configuration
  network    = var.vpc_name
  subnetwork = var.subnet_name
  
  # IP allocation policy for VPC-native networking
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }
  
  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = false  # Keep public endpoint for easier access
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    
    master_global_access_config {
      enabled = true
    }
  }
  
  # Master authorized networks - allow all for initial setup
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks (update for production)"
    }
  }
  
  # Workload Identity configuration
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Release channel
  release_channel {
    channel = "REGULAR"
  }
  
  # Deletion protection
  deletion_protection = var.enable_deletion_protection
  
  # Labels
  resource_labels = merge(var.common_labels, {
    cluster_type = "autopilot"
    application  = "pinky-promise"
  })
  
  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api
  ]
}

# Kubernetes namespaces
resource "kubernetes_namespace" "application" {
  metadata {
    name = var.environment
    
    labels = merge(var.common_labels, {
      environment = var.environment
      managed-by  = "terraform"
    })
  }
  
  depends_on = [google_container_cluster.primary]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    
    labels = merge(var.common_labels, {
      purpose    = "monitoring"
      managed-by = "terraform"
    })
  }
  
  depends_on = [google_container_cluster.primary]
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
    
    labels = merge(var.common_labels, {
      purpose    = "ingress"
      managed-by = "terraform"
    })
  }
  
  depends_on = [google_container_cluster.primary]
}

