# Networking Module - VPC and Subnets

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-pinky-promise-vpc"
  auto_create_subnetworks = false
  routing_mode           = "REGIONAL"
  
  project = var.project_id
  
  description = "VPC network for Pinky Promise application"
}

# Public Subnet (for Load Balancer, NAT Gateway)
resource "google_compute_subnetwork" "public" {
  name          = "${var.environment}-public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  
  project = var.project_id
  
  description = "Public subnet for load balancer and NAT gateway"
}

# Private Subnet (for GKE Cluster)
resource "google_compute_subnetwork" "private" {
  name          = "${var.environment}-private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  
  project = var.project_id
  
  # Secondary IP ranges for GKE
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
  
  # Enable private Google access
  private_ip_google_access = true
  
  description = "Private subnet for GKE cluster with secondary ranges for pods and services"
}

# Database Subnet (for Cloud SQL)
resource "google_compute_subnetwork" "database" {
  name          = "${var.environment}-database-subnet"
  ip_cidr_range = var.database_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  
  project = var.project_id
  
  # Enable private Google access
  private_ip_google_access = true
  
  description = "Private subnet for database instances"
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "router" {
  name    = "${var.environment}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  
  project = var.project_id
  
  description = "Cloud Router for NAT Gateway"
}

# Cloud NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  project = var.project_id
  
  # Configure logging
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rules

# Allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.environment}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.vpc_cidr]
  
  description = "Allow internal communication within VPC"
}

# Allow SSH from IAP
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.environment}-allow-iap-ssh"
  network = google_compute_network.vpc.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  # IAP's IP range
  source_ranges = ["35.235.240.0/20"]
  
  description = "Allow SSH access from Identity-Aware Proxy"
}

# Allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.environment}-allow-health-checks"
  network = google_compute_network.vpc.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  
  # Google Cloud health check IP ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  
  description = "Allow Google Cloud health checks"
}

# Allow HTTPS/HTTP from internet (for load balancer)
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.environment}-allow-http-https"
  network = google_compute_network.vpc.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["http-server", "https-server"]
  
  description = "Allow HTTP and HTTPS traffic from internet"
}

# Private Service Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.environment}-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  
  project = var.project_id
  
  description = "Private IP range for Cloud SQL"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  depends_on = [google_compute_global_address.private_ip_address]
}

