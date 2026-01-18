terraform {
  required_version = ">= 1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 7.0.0"
    }
  }
}

/******************************************
  GA Provider configuration
 *****************************************/
provider "google" {
  project = module.constants.gcp_project
}

/******************************************
  Beta Provider configuration
 *****************************************/
provider "google-beta" {
  project = module.constants.gcp_project
}
