# Security Module - IAM, Service Accounts, and Secret Manager

# Enable required APIs
resource "google_project_service" "secretmanager_api" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
  
  disable_dependent_services = true
}

resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
  
  disable_dependent_services = true
}

# Workload Identity Service Account for GKE
resource "google_service_account" "workload_identity" {
  project      = var.project_id
  account_id   = "${var.environment}-workload-identity"
  display_name = "Workload Identity Service Account for ${var.environment}"
  description  = "Service account for Kubernetes workloads with Workload Identity"
}

# Cloud SQL Proxy Service Account
resource "google_service_account" "cloudsql_proxy" {
  project      = var.project_id
  account_id   = "${var.environment}-cloudsql-proxy"
  display_name = "Cloud SQL Proxy Service Account for ${var.environment}"
  description  = "Service account for Cloud SQL proxy connections"
}

# IAM bindings for Workload Identity
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.workload_identity.name
  role               = "roles/iam.workloadIdentityUser"
  
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.environment}/pinky-promise-backend]",
    "serviceAccount:${var.project_id}.svc.id.goog[${var.environment}/pinky-promise-frontend]"
  ]
  
  depends_on = [var.workload_identity_pool]
}

# IAM bindings for Cloud SQL
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}

# IAM bindings for Secret Manager
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}

# IAM bindings for monitoring
resource "google_project_iam_member" "monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}

# IAM bindings for Cloud Trace
resource "google_project_iam_member" "trace_agent" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}

# Application secrets in Secret Manager
resource "google_secret_manager_secret" "jwt_secret" {
  project   = var.project_id
  secret_id = "${var.environment}-jwt-secret"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "google_secret_manager_secret_version" "jwt_secret" {
  secret      = google_secret_manager_secret.jwt_secret.id
  secret_data = random_password.jwt_secret.result
}

resource "google_secret_manager_secret" "jwt_refresh_secret" {
  project   = var.project_id
  secret_id = "${var.environment}-jwt-refresh-secret"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

resource "random_password" "jwt_refresh_secret" {
  length  = 64
  special = true
}

resource "google_secret_manager_secret_version" "jwt_refresh_secret" {
  secret      = google_secret_manager_secret.jwt_refresh_secret.id
  secret_data = random_password.jwt_refresh_secret.result
}

resource "google_secret_manager_secret" "recaptcha_secret" {
  project   = var.project_id
  secret_id = "${var.environment}-recaptcha-secret"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

# Placeholder for reCAPTCHA secret (to be updated manually)
resource "google_secret_manager_secret_version" "recaptcha_secret" {
  secret      = google_secret_manager_secret.recaptcha_secret.id
  secret_data = "PLACEHOLDER_RECAPTCHA_SECRET_KEY"
  
  lifecycle {
    ignore_changes = [secret_data]
  }
}

# Node.js environment configuration
resource "google_secret_manager_secret" "node_env" {
  project   = var.project_id
  secret_id = "${var.environment}-node-env"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "node_env" {
  secret      = google_secret_manager_secret.node_env.id
  secret_data = var.environment == "production" ? "production" : "development"
}

# Container Registry IAM
resource "google_project_iam_member" "gcr_reader" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
  
  depends_on = [
    google_project_service.secretmanager_api,
    google_project_service.iam_api
  ]
}

