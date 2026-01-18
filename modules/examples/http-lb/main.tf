terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.zone
}

module "http_lb" {
  source = "../../modules/networking/http-lb"

  gcp_project = var.gcp_project
  lb_name     = var.lb_name

  # Attach LB to your existing MIG backend
  zone     = var.zone
  mig_name = var.mig_name

  # Health check for the backend service
  health_check_self_link = var.health_check_self_link

  # Backend listens on this port (your MIG should define named_port "http")
  server_port = var.server_port

  # Optional: route everything to backend (equivalent to listener_rule values=["*"])
  # If your module doesn’t take this yet, you can omit it.
  path_matcher_paths = ["/*"]
}
