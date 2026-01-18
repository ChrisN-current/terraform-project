variable "gcp_project" {
  description = "GCP project id"
  type        = string
}

variable "gcp_region" {
  description = "GCP region (not strictly required for the global LB, but used by provider and other resources)"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone where the MIG lives (e.g. us-central1-a)"
  type        = string
  default     = "us-central1-a"
}

variable "lb_name" {
  description = "Base name for the HTTP load balancer resources"
  type        = string
  default     = "terraform-up-and-running"
}

variable "mig_name" {
  description = "Name of the zonal managed instance group to attach as the backend"
  type        = string
}

variable "health_check_self_link" {
  description = "Self link of the google_compute_health_check used by the backend service"
  type        = string
}

variable "server_port" {
  description = "Backend service port (matches MIG named_port 'http')"
  type        = number
  default     = 8080
}
