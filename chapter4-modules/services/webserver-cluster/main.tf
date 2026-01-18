resource "google_compute_instance_template" "example" {
  name_prefix = "web-template-"
  machine_type = var.machine_type

  disk {
    source_image = var.server_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = "default"
    access_config {} # ensures public IP for testing if needed
  }

metadata = {
  startup-script = templatefile("${path.module}/user-data.sh", {
    db_username = data.terraform_remote_state.db.outputs.db_username
    db_password = data.terraform_remote_state.db.outputs.db_password
    db_name     = data.terraform_remote_state.db.outputs.db_name
    server_port = var.server_port
    server_text = var.server_text
  })
}

  tags = ["web-server"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "web_mig" {
  name               = "${var.cluster_name}-mig"
  base_instance_name = "web"
  zone               = "us-central1-a"

  version {
    instance_template = google_compute_instance_template.example.id
  }

  update_policy {
    type                 = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0  # ≈ min_elb_capacity
  }

  target_size = var.target_size

  named_port {
    name = "http"
    port = var.server_port
  }

  lifecycle {
    create_before_destroy = true
# GCP doesn't support multi zone mig's in this way
    # precondition {
    #   condition     = length(var.zones) > 1
    #   error_message = "You must use more than one zone for high availability."
    # }
  }
}

resource "google_compute_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  zone   = module.constants.gcp_region
  target = google_compute_instance_group_manager.web_mig.id

  autoscaling_policy {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_cloud_scheduler_job" "scale_up" {
  count            = var.enable_autoscaling ? 1 : 0
  name             = "${var.cluster_name}-scale-up-9am"
  schedule         = var.scale_up_time
  time_zone        = "America/New_York"
  region           = var.scheduler_region
  http_target {
    http_method = "POST"
    uri         = "https://compute.googleapis.com/compute/v1/projects/${var.gcp_project}/zones/us-central1-a/instanceGroupManagers/${google_compute_instance_group_manager.web_mig.name}/resize?size=10"
    oauth_token {
      service_account_email = var.scheduler_service_account
    }
  }
}

resource "google_cloud_scheduler_job" "scale_down" {
  count            = var.enable_autoscaling ? 1 : 0
  name             = "${var.cluster_name}-scale-down-5pm"
  schedule         = var.scale_down_time
  time_zone        = "America/New_York"
  region           = var.scheduler_region
  http_target {
    http_method = "POST"
    uri         = "https://compute.googleapis.com/compute/v1/projects/${var.gcp_project}/zones/us-central1-a/instanceGroupManagers/${google_compute_instance_group_manager.web_mig.name}/resize?size=10"
    oauth_token {
      service_account_email = var.scheduler_service_account
    }
  }
}

resource "google_compute_health_check" "web_hc" {
  name = "${var.cluster_name}-web-health-check"

  http_health_check {
    port         = var.server_port
    request_path = "/"
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

resource "google_compute_backend_service" "web_backend" {
  name                  = "${var.cluster_name}-web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.web_hc.id]

  backend {
    group = google_compute_instance_group_manager.web_mig.instance_group
  }
}

resource "google_compute_url_map" "web_map" {
  name            = "${var.cluster_name}-web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "web_proxy" {
  name   = "${var.cluster_name}-web-proxy"
  url_map = google_compute_url_map.web_map.id
}

resource "google_compute_global_address" "web_ip" {
  name = "web-static-ip"
}

resource "google_compute_global_forwarding_rule" "web_forward" {
  name       = "${var.cluster_name}-web-forwarding-rule"
  target     = google_compute_target_http_proxy.web_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.web_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_firewall" "allow_clients" {
  name    = "${var.cluster_name}-allow-web-clients"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

resource "google_compute_firewall" "allow_healthchecks" {
  name    = "${var.cluster_name}-allow-health-checks"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["web-server"]
}

resource "google_dns_record_set" "app_record" {
  name         = "chris-terraform-project.com."
  managed_zone = "chris-terraform-project-com"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.web_ip.address]
}

data "terraform_remote_state" "db" {
  backend = "gcs"

  config = {
    bucket = var.db_remote_state_bucket
    prefix = "CHRIS-MYSQL"
  }
}