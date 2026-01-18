terraform {
    required_providers {
      google = {
        source  = "hashicorp/google"
        version = ">= 4.0.0"
      }
    }
}

provider "google" {
    region = "us-east1"
    project = var.gcp_project
    alias  = "region_1"
}

provider "google" {
    region = "us-central1"
    project = var.gcp_project
    alias  = "region_2"
}

