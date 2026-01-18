locals {
  mig_resize_uri = "https://compute.googleapis.com/compute/v1/projects/${var.gcp_project}/zones/${var.zone}/instanceGroupManagers/${google_compute_instance_group_manager.web_mig.name}/resize"
}

# Instance Template

resource "google_compute_instance_template" "example" {
  name_prefix  = "${var.cluster_name}-tpl-"
  machine_type = var.machine_type

  disk {
    source_image = var.server_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    # Public IP optional
    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {}
    }
  }

  metadata = {
    startup-script = var.user_data
  }

  tags = var.instance_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Managed Instance Group

resource "google_compute_instance_group_manager" "web_mig" {
  name               = "${var.cluster_name}-mig"
  base_instance_name = var.base_instance_name
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.example.self_link
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = var.max_surge_fixed
    max_unavailable_fixed = var.max_unavailable_fixed
  }

  target_size = var.target_size

  named_port {
    name = var.named_port_name
    port = var.server_port
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaler

resource "google_compute_autoscaler" "web_autoscaler" {
  count  = var.enable_autoscaling ? 1 : 0

  name   = "${var.cluster_name}-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.web_mig.self_link

  autoscaling_policy {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    cpu_utilization {
      target = var.target_cpu_utilization
    }

    cooldown_period = var.cooldown_period
  }
}

resource "google_cloud_scheduler_job" "scale_up" {

  count = var.enable_autoscaling ? 1 : 0

  name      = "${var.cluster_name}-scale-up"
  schedule  = var.scale_up_time
  time_zone = var.time_zone
  region    = var.scheduler_region

  http_target {
    http_method = "POST"
    uri         = "${local.mig_resize_uri}?size=${var.scale_up_size}"

    oauth_token {
      service_account_email = var.scheduler_service_account
    }
  }
}

resource "google_cloud_scheduler_job" "scale_down" {

  count = var.enable_autoscaling ? 1 : 0

  name      = "${var.cluster_name}-scale-down"
  schedule  = var.scale_down_time
  time_zone = var.time_zone
  region    = var.scheduler_region

  http_target {
    http_method = "POST"
    uri         = "${local.mig_resize_uri}?size=${var.scale_down_size}"

    oauth_token {
      service_account_email = var.scheduler_service_account
    }
  }
}

# Health check
resource "google_compute_health_check" "web_hc" {
  name = "${var.cluster_name}-web-health-check"

  check_interval_sec  = var.health_check_interval_sec
  timeout_sec         = var.health_check_timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}
