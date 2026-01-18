resource "google_project_iam_member" "example" {
  for_each = toset(var.usernames)

  project = module.constants.gcp_project
  role    = "roles/viewer"
  member  = "user:${each.key}"
}
