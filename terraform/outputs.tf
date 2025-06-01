# Pinky Promise App - Terraform Outputs

# Project Information
output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}

# Networking Outputs
output "vpc_name" {
  description = "Name of the VPC network"
  value       = module.networking.vpc_name
}

output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = module.networking.vpc_self_link
}

output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = module.networking.public_subnet_name
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = module.networking.private_subnet_name
}

output "database_subnet_name" {
  description = "Name of the database subnet"
  value       = module.networking.database_subnet_name
}

# GKE Cluster Outputs
output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.gke_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the GKE cluster"
  value       = module.gke_cluster.cluster_location
}

# Database Outputs
output "database_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.database.instance_name
}

output "database_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = module.database.connection_name
}

output "database_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.database.private_ip_address
}

output "database_public_ip" {
  description = "Public IP address of the Cloud SQL instance (if enabled)"
  value       = module.database.public_ip_address
}

output "database_replica_connection_name" {
  description = "Connection name of the read replica (if enabled)"
  value       = module.database.replica_connection_name
}

# Security Outputs
output "workload_identity_service_account" {
  description = "Email of the Workload Identity service account"
  value       = module.security.workload_identity_service_account
}

output "cloudsql_service_account" {
  description = "Email of the Cloud SQL service account"
  value       = module.security.cloudsql_service_account
}

# Secret Manager Outputs
output "secret_names" {
  description = "Names of created secrets in Secret Manager"
  value       = module.security.secret_names
}

# Monitoring Outputs
output "monitoring_dashboard_url" {
  description = "URL to the monitoring dashboard"
  value       = module.monitoring.dashboard_url
}

output "alerting_policies" {
  description = "List of created alerting policies"
  value       = module.monitoring.alerting_policies
}

# Kubectl Configuration Command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id}"
}

# Connection Information
output "connection_info" {
  description = "Information for connecting to the infrastructure"
  value = {
    cluster_name     = module.gke_cluster.cluster_name
    cluster_location = module.gke_cluster.cluster_location
    database_host    = module.database.private_ip_address
    database_name    = var.database_name
    vpc_name         = module.networking.vpc_name
  }
}

