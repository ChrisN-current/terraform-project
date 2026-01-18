resource "google_storage_bucket_iam_member" "allow_terraform_service_account" {
  bucket = "terraform-state-chris-terraform-project"
  role   = "roles/storage.admin"
  member = "serviceAccount:github-actions@current-production.iam.gserviceaccount.com"
}