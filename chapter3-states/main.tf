provider "google"{
    region = modules.constants.gcp_region
}

resource "google_storage_bucket" "terraform_state" {
    name = "terraform-up-and-running-state"
    location = "US-EAST1"


}