# GKE Cluster Module Outputs

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "ID of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "cluster_master_version" {
  description = "Master version of the GKE cluster"
  value       = google_container_cluster.primary.master_version
}

output "workload_identity_pool" {
  description = "Workload Identity pool for the cluster"
  value       = google_container_cluster.primary.workload_identity_config[0].workload_pool
}

output "application_namespace" {
  description = "Application namespace name"
  value       = kubernetes_namespace.application.metadata[0].name
}

output "monitoring_namespace" {
  description = "Monitoring namespace name"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "ingress_namespace" {
  description = "Ingress namespace name"
  value       = kubernetes_namespace.ingress.metadata[0].name
}

output "cluster_self_link" {
  description = "Self link of the GKE cluster"
  value       = google_container_cluster.primary.self_link
}

output "services_ipv4_cidr" {
  description = "IPv4 CIDR block for services"
  value       = google_container_cluster.primary.services_ipv4_cidr
}

output "cluster_ipv4_cidr" {
  description = "IPv4 CIDR block for cluster"
  value       = google_container_cluster.primary.cluster_ipv4_cidr
}

