# REQUIRED (GCP additions)
variable "gcp_project" {
  description = "The GCP project to deploy into"
  type        = string
}

variable "zone" {
  description = "Zone where the MIG lives (e.g. us-central1-a)"
  type        = string
}

variable "network" {
  description = "VPC network (name or self_link)"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork (name or self_link)"
  type        = string
}

# EXISTING REQUIRED (kept)
variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "min_size" {
  description = "The minimum number of instances in the MIG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of instances in the MIG"
  type        = number
}

variable "enable_autoscaling" {
  description = "If set to true, enable autoscaling"
  type        = bool
}

# Remote state in GCS now
variable "db_remote_state_bucket" {
  description = "The name of the GCS bucket used for the database remote state storage"
  type        = string
}

variable "db_remote_state_key" {
  description = "The prefix in the GCS bucket used for the database remote state storage"
  type        = string
}

# OPTIONAL (kept names, but semantics change slightly on GCP)
variable "ami" {
  description = "GCP source image: self_link or image family string"
  type        = string
}

variable "instance_type" {
  description = "GCP machine type (e.g. e2-micro)"
  type        = string
  default     = "e2-micro"
}

variable "server_text" {
  description = "The text the web server should return"
  type        = string
  default     = "Hello, World"
}

variable "custom_tags" {
  description = "Custom labels/tags to set on the instances"
  type        = map(string)
  default     = {}
}

variable "name" {
  type    = string
  default = "example-vm"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "ssh_user" {
  type    = string
  default = "debian"
}

# Don’t leave this as 0.0.0.0/0 in real environments
variable "ssh_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
