# define GCP region
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-east1"
}
# define GCP project id
variable "gcp_project" {
  type    = string
  default = "chris-terraform-project"
}

variable "terraform_service_account" {
  type    = string
  default = "terraform@chris-terraform-project.iam.gserviceaccount.com"
}
