# Database Module - Cloud SQL PostgreSQL

# Enable required APIs
resource "google_project_service" "sql_admin_api" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
  
  disable_dependent_services = true
}

resource "google_project_service" "servicenetworking_api" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
  
  disable_dependent_services = true
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Store database password in Secret Manager
resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "${var.environment}-db-password"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${var.environment}-pinky-promise-db"
  database_version = "POSTGRES_14"
  region           = var.region
  project          = var.project_id
  
  deletion_protection = var.enable_deletion_protection
  
  settings {
    tier              = var.database_tier
    availability_type = var.enable_high_availability ? "REGIONAL" : "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = var.disk_size
    disk_autoresize   = true
    
    # Backup configuration
    backup_configuration {
      enabled                        = var.enable_backup
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      location                       = var.backup_location
      
      backup_retention_settings {
        retained_backups = var.backup_retention_days
        retention_unit   = "COUNT"
      }
    }
    
    # IP configuration - private only
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc_name
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                      = "ENCRYPTED_ONLY"
    }
    
    # Database flags for security and performance
    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
    
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
    
    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }
    
    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"  # Log queries taking more than 1 second
    }
    
    # Maintenance window
    maintenance_window {
      day          = 7  # Sunday
      hour         = 3  # 3 AM
      update_track = "stable"
    }
    
    # Insights configuration
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
    
    user_labels = merge(var.common_labels, {
      component = "database"
      type      = "primary"
    })
  }
  
  depends_on = [
    google_project_service.sql_admin_api,
    google_project_service.servicenetworking_api
  ]
}

# Database
resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Database user
resource "google_sql_user" "main" {
  name     = var.database_user
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
  project  = var.project_id
}

# Read replica (conditional)
resource "google_sql_database_instance" "read_replica" {
  count = var.enable_read_replica ? 1 : 0
  
  name                 = "${var.environment}-pinky-promise-db-replica"
  database_version     = "POSTGRES_14"
  region               = var.replica_region != "" ? var.replica_region : var.region
  project              = var.project_id
  master_instance_name = google_sql_database_instance.main.name
  
  deletion_protection = var.enable_deletion_protection
  
  replica_configuration {
    failover_target = false
  }
  
  settings {
    tier              = var.replica_tier
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    
    # IP configuration - private only
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc_name
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                      = "ENCRYPTED_ONLY"
    }
    
    # Insights configuration
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
    
    user_labels = merge(var.common_labels, {
      component = "database"
      type      = "replica"
    })
  }
  
  depends_on = [google_sql_database_instance.main]
}

# SSL certificate
resource "google_sql_ssl_cert" "client_cert" {
  common_name = "${var.environment}-pinky-promise-client"
  instance    = google_sql_database_instance.main.name
  project     = var.project_id
}

# Store SSL certificate in Secret Manager
resource "google_secret_manager_secret" "ssl_cert" {
  project   = var.project_id
  secret_id = "${var.environment}-db-ssl-cert"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ssl_cert" {
  secret      = google_secret_manager_secret.ssl_cert.id
  secret_data = google_sql_ssl_cert.client_cert.cert
}

resource "google_secret_manager_secret" "ssl_key" {
  project   = var.project_id
  secret_id = "${var.environment}-db-ssl-key"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ssl_key" {
  secret      = google_secret_manager_secret.ssl_key.id
  secret_data = google_sql_ssl_cert.client_cert.private_key
}

# Store database connection string in Secret Manager
resource "google_secret_manager_secret" "database_url" {
  project   = var.project_id
  secret_id = "${var.environment}-database-url"
  
  labels = var.common_labels
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_url" {
  secret = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${google_sql_user.main.name}:${random_password.db_password.result}@${google_sql_database_instance.main.private_ip_address}:5432/${google_sql_database.main.name}?sslmode=require"
}

