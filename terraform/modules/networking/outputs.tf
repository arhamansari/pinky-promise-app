# Networking Module Outputs

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = google_compute_subnetwork.public.name
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = google_compute_subnetwork.public.id
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private.name
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = google_compute_subnetwork.private.id
}

output "database_subnet_name" {
  description = "Name of the database subnet"
  value       = google_compute_subnetwork.database.name
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = google_compute_subnetwork.database.id
}

output "pods_range_name" {
  description = "Name of the pods secondary IP range"
  value       = google_compute_subnetwork.private.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Name of the services secondary IP range"
  value       = google_compute_subnetwork.private.secondary_ip_range[1].range_name
}

output "private_vpc_connection_name" {
  description = "Name of the private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection.network
}

output "nat_gateway_name" {
  description = "Name of the NAT gateway"
  value       = google_compute_router_nat.nat.name
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.router.name
}

