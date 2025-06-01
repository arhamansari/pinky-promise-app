# Security Module Outputs

output "workload_identity_service_account" {
  description = "Email of the Workload Identity service account"
  value       = google_service_account.workload_identity.email
}

output "cloudsql_service_account" {
  description = "Email of the Cloud SQL service account"
  value       = google_service_account.cloudsql_proxy.email
}

output "secret_names" {
  description = "Names of created secrets in Secret Manager"
  value = {
    jwt_secret         = google_secret_manager_secret.jwt_secret.secret_id
    jwt_refresh_secret = google_secret_manager_secret.jwt_refresh_secret.secret_id
    recaptcha_secret   = google_secret_manager_secret.recaptcha_secret.secret_id
    node_env          = google_secret_manager_secret.node_env.secret_id
  }
}

output "workload_identity_sa_name" {
  description = "Name of the Workload Identity service account"
  value       = google_service_account.workload_identity.name
}

output "cloudsql_sa_name" {
  description = "Name of the Cloud SQL service account"
  value       = google_service_account.cloudsql_proxy.name
}

