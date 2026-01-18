variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = null
}

variable "high_availability" {
  description = "Enable high availability (regional) configuration"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to retain backups. Must be > 0 to enable replication."
  type        = number
  default     = null
}

variable "replicate_source_db" {
  description = "If true, create a read replica of this instance."
  type        = bool
  default     = false
}

