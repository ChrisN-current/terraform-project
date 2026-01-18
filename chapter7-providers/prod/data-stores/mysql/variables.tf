variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-east1"
}

variable "gcp_project" {
  type    = string
  default = "chris-terraform-project"
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = null
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}