locals {
  http_port    = ["8080"]
  all_ips      = ["0.0.0.0/0"]
  tcp_protocol = "tcp"
}

module "webserver-cluster" {
  source = "../../../chapter4-modules/services/webserver-cluster"

  gcp_project = module.constants.gcp_project
  scheduler_region = module.constants.gcp_region
  cluster_name = "webserver-cluster-prod"
  machine_type = "e2-micro"
  target_size  = 4
  min_replicas = 4
  max_replicas = 8
  scale_up_size = 8
  scale_down_size = 4
  enable_autoscaling = true
  scale_up_time = "0 9 * * *"   # 9 AM every day
  scale_down_time = "0 17 * * *" # 5 PM every day
  db_remote_state_bucket = "terraform-state-chris-terraform-project"
  db_remote_state_key    = "prod/services/data-stores/mysql/terraform.tfstate"
  db_username = var.db_username
  db_password = var.db_password
  db_name     = var.db_name
  server_port = var.server_port
  scheduler_service_account = module.constants.terraform_service_account
}

data "google_compute_network" "default_vpc" {
  name = "default"
}

# Fetch the default subnet
data "google_compute_subnetwork" "default_subnet" {
  name   = "default"
  region = module.constants.gcp_region
}

resource "google_compute_security_policy" "cloud_armor_policy" {
  name        = "default-cloud-armor-policy"
  description = "Cloud Armor Policy to deny all traffic by default"
  type        = "CLOUD_ARMOR"
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}

# Allow traffic from the default VPC CIDR block
resource "google_compute_security_policy_rule" "allow_default_vpc" {
  security_policy = google_compute_security_policy.cloud_armor_policy.name
  description     = "Allow traffic from the default VPC"
  priority        = 1000 # Higher priority than the default deny rule
  action          = "allow"

  match {
    versioned_expr = "SRC_IPS_V1"
    config {
      src_ip_ranges = [
        data.google_compute_subnetwork.default_subnet.ip_cidr_range
      ]
    }
  }

  preview = false
}

# Add a rule to deny all traffic by default
resource "google_compute_security_policy_rule" "default_deny" {
  security_policy = google_compute_security_policy.cloud_armor_policy.name
  description     = "Deny all traffic by default"
  priority        = 2147483647 # Default deny rule should have the lowest priority
  action          = "deny"

  match {
    versioned_expr = "SRC_IPS_V1"
    config {
      src_ip_ranges = ["*"]
    }
  }

  preview = false
}

resource "google_compute_firewall" "allow_8080" {
  name    = "allow-8080-ingress"
  network = "default"

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = local.tcp_protocol
    ports    = local.http_port
  }

  source_ranges = local.all_ips
  target_tags   = ["allow-8080"] # Add this tag to instances that should receive this traffic
}

