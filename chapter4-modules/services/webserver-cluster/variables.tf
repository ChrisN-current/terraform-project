module "constants" {
  source = "../../../constants"
}

module "IAM_constants" {
  source = "../../../../../base/IAM/constants"
}

variable "gcp_project" {
  description = "The GCP project to deploy into"
  type        = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
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

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "example_database_stage"
}

variable "cluster_name" {
  description = "The name of the instance group manager and related resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the GCS bucket where the remote state for the database is stored"
  type        = string
}

variable "db_remote_state_key" {
  description = "The key within the GCS bucket where the remote state for the database is stored"
  type        = string
}

variable "machine_type" {
  description = "The machine type to use for the web server instances"
  type        = string
}

variable "target_size" {
  description = "The minimum number of instances in the instance group"
  type        = number
}

variable "min_replicas" {
  description = "The minimum number of instances for the autoscaler"
  type        = number
}

variable "max_replicas" {
  description = "The maximum number of instances for the autoscaler"
  type        = number
}

variable "scale_up_size" {
  description = "Number of replicas when scaling up"
  type        = number
}

variable "scale_up_time" {
  description = "Cron schedule for scaling up"
  type        = string
}

variable "scale_down_size" {
  description = "Number of replicas when scaling down"
  type        = number
}

variable "scale_down_time" {
  description = "Cron schedule for scaling down"
  type        = string
}

variable "time_zone" {
  description = "Time zone for the schedules"
  type        = string
  default     = "UTC"
}

variable "scheduler_service_account" {
  description = "The email of the service account to attach to the instances"
  type        = string
}

variable "scheduler_region" {
  description = "Region where the Cloud Scheduler job will run"
  type        = string
}

variable "enable_autoscaling" {
  description = "Enable or disable autoscaling"
  type        = bool
}

variable "server_image" {
  description = "The image to use for the web server instances"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "server_text" {
  description = "Text to display on the web server"
  type        = string
  default     = "Hello, World!"
}

# variable "zones" {
#   description = "List of zones for the instance group"
#   type        = list(string)
#   default     = ["us-east1-a", "us-east1-b"]
# }