output "gcp_region" {
  value       = var.gcp_region
  description = "GCP region"
}

output "gcp_project" {
  value       = var.gcp_project
  description = "GCP project"
}

output "terraform_service_account" {
  value       = var.terraform_service_account
  description = "GCP service account"
}
