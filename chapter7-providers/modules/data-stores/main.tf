

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
    tier             = "db-f1-micro"
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"

    disk_size = 10
    disk_type = "PD_SSD"

    backup_configuration {
      enabled = var.backup_retention_period != null && var.backup_retention_period > 0

      backup_retention_settings {
        retained_backups = coalesce(var.backup_retention_period, 7)
        retention_unit   = "COUNT"
      }

      start_time = "03:00"
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

    maintenance_window {
      day          = 7
      hour         = 4
      update_track = "stable"
    }
  }

  deletion_protection = false
}

resource "google_sql_database_instance" "replica" {
  count = var.replicate_source_db ? 1 : 0

  name                 = "${google_sql_database_instance.example.name}-replica"
  region               = module.constants.gcp_region
  database_version     = "MYSQL_8_0"
  master_instance_name = google_sql_database_instance.example.name
}





