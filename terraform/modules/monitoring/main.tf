# Monitoring Module - Cloud Monitoring and Alerting

# Enable required APIs
resource "google_project_service" "monitoring_api" {
  project = var.project_id
  service = "monitoring.googleapis.com"
  
  disable_dependent_services = true
}

resource "google_project_service" "logging_api" {
  project = var.project_id
  service = "logging.googleapis.com"
  
  disable_dependent_services = true
}

# Notification channel for alerts
resource "google_monitoring_notification_channel" "email" {
  display_name = "${var.environment} Email Alerts"
  type         = "email"
  project      = var.project_id
  
  labels = {
    email_address = var.alert_email
  }
  
  enabled = true
}

# Alert policy for high CPU usage
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "${var.environment} - High CPU Usage"
  project      = var.project_id
  combiner     = "OR"
  enabled      = true
  
  conditions {
    display_name = "GKE container CPU usage"
    
    condition_threshold {
      filter          = "resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = ["resource.labels.container_name"]
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
  
  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert policy for high memory usage
resource "google_monitoring_alert_policy" "high_memory" {
  display_name = "${var.environment} - High Memory Usage"
  project      = var.project_id
  combiner     = "OR"
  enabled      = true
  
  conditions {
    display_name = "GKE container Memory usage"
    
    condition_threshold {
      filter          = "resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.9
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = ["resource.labels.container_name"]
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
  
  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert policy for pod restart frequency
resource "google_monitoring_alert_policy" "pod_restarts" {
  display_name = "${var.environment} - Frequent Pod Restarts"
  project      = var.project_id
  combiner     = "OR"
  enabled      = true
  
  conditions {
    display_name = "Pod restart rate"
    
    condition_threshold {
      filter          = "resource.type=\"k8s_pod\" resource.labels.cluster_name=\"${var.cluster_name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 3
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields = ["resource.labels.pod_name"]
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
  
  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert policy for database connections
resource "google_monitoring_alert_policy" "database_connections" {
  display_name = "${var.environment} - High Database Connections"
  project      = var.project_id
  combiner     = "OR"
  enabled      = true
  
  conditions {
    display_name = "Cloud SQL connection count"
    
    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 80
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
  
  alert_strategy {
    auto_close = "1800s"
  }
}

# Dashboard for application monitoring
resource "google_monitoring_dashboard" "main" {
  dashboard_json = jsonencode({
    displayName = "${var.environment} Pinky Promise App Dashboard"
    
    gridLayout = {
      widgets = [
        {
          title = "GKE CPU Usage"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\""
                  aggregation = {
                    alignmentPeriod = "60s"
                    perSeriesAligner = "ALIGN_RATE"
                    crossSeriesReducer = "REDUCE_MEAN"
                    groupByFields = ["resource.labels.container_name"]
                  }
                }
              }
              plotType = "LINE"
            }]
          }
        },
        {
          title = "GKE Memory Usage"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\""
                  aggregation = {
                    alignmentPeriod = "60s"
                    perSeriesAligner = "ALIGN_MEAN"
                    crossSeriesReducer = "REDUCE_MEAN"
                    groupByFields = ["resource.labels.container_name"]
                  }
                }
              }
              plotType = "LINE"
            }]
          }
        },
        {
          title = "Database Connections"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"cloudsql_database\""
                  aggregation = {
                    alignmentPeriod = "60s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
              plotType = "LINE"
            }]
          }
        }
      ]
    }
  })
  
  project = var.project_id
  
  depends_on = [
    google_project_service.monitoring_api
  ]
}

