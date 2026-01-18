variable "gcp_project" {
  description = "GCP project id"
  type        = string
}

variable "gcp_region" {
  description = "GCP region (e.g. us-central1)"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-east1-b"
}

variable "cluster_name" {
  description = "Base name for the cluster"
  type        = string
  default     = "terraform-up-and-running"
}
