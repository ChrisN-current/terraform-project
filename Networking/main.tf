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
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-8080"] # Add this tag to instances that should receive this traffic
}

