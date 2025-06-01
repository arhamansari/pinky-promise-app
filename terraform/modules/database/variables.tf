# Database Module Variables

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

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "pinky_promise"
}

variable "database_user" {
  description = "Database user name"
  type        = string
  default     = "postgres"
}

variable "database_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-custom-2-4096"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "enable_high_availability" {
  description = "Enable high availability (regional)"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "backup_location" {
  description = "Backup location"
  type        = string
  default     = "us"
}

variable "enable_read_replica" {
  description = "Enable read replica"
  type        = bool
  default     = true
}

variable "replica_tier" {
  description = "Read replica instance tier"
  type        = string
  default     = "db-custom-1-3840"
}

variable "replica_region" {
  description = "Read replica region (empty for same region)"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

