# Monitoring Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "admin@example.com"
}

variable "enable_alerting" {
  description = "Enable alerting policies"
  type        = bool
  default     = true
}

