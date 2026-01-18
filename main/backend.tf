terraform {
  backend "gcs" {
    bucket = "terraform-state-chris-terraform-project"
    prefix = "main"
  }
}
