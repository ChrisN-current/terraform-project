provider "google" {
    region  = "us-east1"
    project = var.gcp_project
    alias   = "primary"
}

provider "google" {
    region  = "us-central1"
    project = var.gcp_project
    alias   = "replica"
}