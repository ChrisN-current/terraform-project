## This is the file where permissions are assigned. Identies are created elsewhere

resource "google_project_iam_binding" "project_owner" {
  project = module.constants.gcp_project
  role    = "roles/owner"

  members = concat(module.IAM_constants.project_owners, ["user:chris.neal@current.com"])
}

module "terraform-apply-role" {
  source            = "../../../base/IAM/terraform-apply"
  project_id        = module.constants.gcp_project
  state_bucket_name = "terraform-state-${module.constants.gcp_project}"
  members           = [module.IAM_constants.github_actions_runner_account_member]
}

resource "google_project_iam_member" "github_runner_dns_admin" {
  project = "chris-terraform-project"
  role    = "roles/dns.admin"
  member  = module.IAM_constants.github_actions_runner_account_member
}

resource "google_project_iam_member" "github_runner_compute_viewer" {
  project = "chris-terraform-project"
  role    = "roles/compute.viewer"
  member  = module.IAM_constants.github_actions_runner_account_member
}

resource "google_service_account" "scheduler" {
  project      = "chris-terraform-project"
  account_id   = "scheduler-sa"
  display_name = "Scheduler Service Account"
}

resource "google_project_iam_member" "scheduler_instance_admin" {
  project = "chris-terraform-project"
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.scheduler.email}"
}

resource "google_project_iam_member" "scheduler_sa_user" {
  project = "chris-terraform-project"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.scheduler.email}"
}

