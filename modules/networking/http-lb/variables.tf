variable "gcp_project" {
  type        = string
  description = "GCP project id"
}

variable "lb_name" {
  type        = string
  description = "Load balancer base name (like alb_name)"
}

variable "zone" {
  type        = string
  description = "Zone for the MIG (e.g. us-central1-a)"
  default     = "us-central1-a"
}

variable "server_port" {
  type        = number
  description = "Backend service port"
  default     = 8080
}

variable "target_size" {
  description = "The minimum number of instances in the instance group"
  type        = number
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name of the instance group manager and related resources"
  type        = string
}