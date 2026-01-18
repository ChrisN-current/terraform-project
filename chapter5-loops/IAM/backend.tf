terraform {
  backend "gcs" {
    bucket = "terraform-state-chris-terraform-project"
    prefix = "ch5-loops"
  }
}
