variable "gcp_project" {
  type        = string
  description = "GCP project id"
}

variable "cluster_name" {
  type        = string
  description = "Base name for resources"
}

variable "zone" {
  type        = string
  description = "Zone where the MIG lives (e.g. us-central1-a)"
}

# Instance template
variable "machine_type" {
  type        = string
  description = "GCP machine type (e.g. e2-micro)"
}

variable "server_image" {
  type        = string
  description = "GCP source image (self_link or family string)"
}

variable "network" {
  type        = string
  description = "VPC network name or self_link"
  default     = "default"
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork name or self_link (optional)"
  default     = null
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to attach a public IP to instances (usually false behind an external HTTP LB)"
  default     = false
}

variable "user_data" {
  type        = string
  description = "Rendered startup script"
}

variable "instance_tags" {
  type        = list(string)
  description = "Network tags applied to instances"
  default     = []
}

variable "base_instance_name" {
  type        = string
  description = "Base instance name for the MIG"
  default     = "web"
}

# MIG sizing / ports
variable "target_size" {
  type        = number
  description = "Initial target size of the MIG"
  default     = 1
}

variable "server_port" {
  type        = number
  description = "Application port; also used for MIG named_port"
  default     = 8080
}

variable "named_port_name" {
  type        = string
  description = "Name used for the MIG named_port (must match backend_service.port_name)"
  default     = "http"
}

# Rolling update
variable "max_surge_fixed" {
  type        = number
  description = "Max surge during proactive updates"
  default     = 1
}

variable "max_unavailable_fixed" {
  type        = number
  description = "Max unavailable during proactive updates"
  default     = 0
}

# Autoscaler
variable "enable_autoscaling" {
  type        = bool
  description = "Enable autoscaler"
  default     = false
}

variable "min_replicas" {
  type        = number
  description = "Min replicas for autoscaler"
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Max replicas for autoscaler"
  default     = 1
}

variable "target_cpu_utilization" {
  type        = number
  description = "Target CPU utilization (0-1)"
  default     = 0.6
}

variable "cooldown_period" {
  type        = number
  description = "Autoscaler cooldown period seconds"
  default     = 60
}

# Scheduled scaling
variable "enable_schedules" {
  type        = bool
  description = "Enable Cloud Scheduler based resizing"
  default     = false
}

variable "scheduler_region" {
  type        = string
  description = "Region where scheduler jobs run (e.g. us-central1)"
  default     = null
}

variable "scheduler_service_account" {
  type        = string
  description = "Service account email scheduler uses to call Compute API"
  default     = null
}

variable "scale_up_time" {
  type        = string
  description = "Cron schedule for scaling up"
  default     = null
}

variable "scale_up_size" {
  type        = number
  description = "Desired size when scaling up"
  default     = null
}

variable "scale_down_time" {
  type        = string
  description = "Cron schedule for scaling down"
  default     = null
}

variable "scale_down_size" {
  type        = number
  description = "Desired size when scaling down"
  default     = null
}

variable "time_zone" {
  type        = string
  description = "Time zone for schedules"
  default     = "America/New_York"
}

# Health check
variable "health_check_port" {
  type        = number
  description = "Port health check uses"
  default     = 8080
}

variable "health_check_path" {
  type        = string
  description = "Path for HTTP health check"
  default     = "/"
}

variable "health_check_interval_sec" {
  type        = number
  description = "Health check interval seconds"
  default     = 10
}

variable "health_check_timeout_sec" {
  type        = number
  description = "Health check timeout seconds"
  default     = 5
}

variable "healthy_threshold" {
  type        = number
  description = "Consecutive successes to mark healthy"
  default     = 2
}

variable "unhealthy_threshold" {
  type        = number
  description = "Consecutive failures to mark unhealthy"
  default     = 2
}
