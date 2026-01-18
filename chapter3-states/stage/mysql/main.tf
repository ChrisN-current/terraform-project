

# Import the constants module
module "constants" {
  source = "../../../constants"
}

provider "google" {
  project = module.constants.gcp_project
  region  = module.constants.gcp_region
}

provider "google-beta" {
  project = module.constants.gcp_project
  region  = module.constants.gcp_region
}


resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = data.google_compute_network.default_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Create a Cloud SQL MySQL instance
resource "google_sql_database_instance" "example" {
  name             = "chris-terraform-mysql"
  database_version = "MYSQL_8_0"
  region           = module.constants.gcp_region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"

    # Optional: Configure for high availability
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"


    disk_size = 10
    disk_type = "PD_SSD"

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled = true
      private_network                               = data.google_compute_network.default_vpc.self_link
      enable_private_path_for_google_cloud_services = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }

    # Optional: Configure maintenance window
    maintenance_window {
      day          = 7 # Sunday
      hour         = 4 # 4 AM
      update_track = "stable"
    }
  }

  deletion_protection = false # Set to true in production
}


