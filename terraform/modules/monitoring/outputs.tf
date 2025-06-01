# Monitoring Module Outputs

output "dashboard_url" {
  description = "URL to the monitoring dashboard"
  value       = "https://console.cloud.google.com/monitoring/dashboards/custom/${google_monitoring_dashboard.main.id}?project=${var.project_id}"
}

output "alerting_policies" {
  description = "List of created alerting policies"
  value = {
    high_cpu           = google_monitoring_alert_policy.high_cpu.name
    high_memory        = google_monitoring_alert_policy.high_memory.name
    pod_restarts       = google_monitoring_alert_policy.pod_restarts.name
    database_connections = google_monitoring_alert_policy.database_connections.name
  }
}

output "notification_channel" {
  description = "Notification channel for alerts"
  value       = google_monitoring_notification_channel.email.name
}

