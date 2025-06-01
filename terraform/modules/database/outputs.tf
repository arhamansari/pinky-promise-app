# Database Module Outputs

output "instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.connection_name
}

output "private_ip_address" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.public_ip_address
}

output "database_name" {
  description = "Name of the database"
  value       = google_sql_database.main.name
}

output "database_user" {
  description = "Database user name"
  value       = google_sql_user.main.name
}

output "replica_connection_name" {
  description = "Connection name of the read replica"
  value       = var.enable_read_replica ? google_sql_database_instance.read_replica[0].connection_name : null
}

output "replica_private_ip" {
  description = "Private IP address of the read replica"
  value       = var.enable_read_replica ? google_sql_database_instance.read_replica[0].private_ip_address : null
}

output "ssl_cert_secret_name" {
  description = "Secret Manager secret name for SSL certificate"
  value       = google_secret_manager_secret.ssl_cert.secret_id
}

output "ssl_key_secret_name" {
  description = "Secret Manager secret name for SSL key"
  value       = google_secret_manager_secret.ssl_key.secret_id
}

output "database_url_secret_name" {
  description = "Secret Manager secret name for database URL"
  value       = google_secret_manager_secret.database_url.secret_id
}

output "db_password_secret_name" {
  description = "Secret Manager secret name for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}

