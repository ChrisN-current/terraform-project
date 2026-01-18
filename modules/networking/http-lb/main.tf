locals {
  http_port = 80
}

# Public IP

resource "google_compute_global_address" "lb_ip" {
  project = var.gcp_project
  name    = "${var.lb_name}-ip"
}

# Backend service -> MIG

data "google_compute_instance_group" "web_ig" {
  project = var.gcp_project
  zone    = var.zone
  name    = google_compute_instance_group_manager.web_mig.instance_group
}

resource "google_compute_backend_service" "web_backend" {
  project               = var.gcp_project
  name                  = "${var.lb_name}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30

  backend {
    group = data.google_compute_instance_group.web_ig.self_link
  }

  health_checks = [google_compute_health_check.web_hc.self_link]
}

# Default 404 response

resource "google_storage_bucket" "lb_404_bucket" {
  project                     = var.gcp_project
  name                        = "${var.lb_name}-404-${var.gcp_project}"
  location                    = "US"
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

resource "google_storage_bucket_object" "lb_404_object" {
  bucket       = google_storage_bucket.lb_404_bucket.name
  name         = "index.html"
  content_type = "text/plain"

  content = "404: page not found"
}

resource "google_compute_backend_bucket" "lb_404_backend" {
  project     = var.gcp_project
  name        = "${var.lb_name}-404-backend"
  bucket_name = google_storage_bucket.lb_404_bucket.name
  enable_cdn  = false
}

# URL map (routes) + HTTP proxy + forwarding rule :80

resource "google_compute_url_map" "http_url_map" {
  project         = var.gcp_project
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_bucket.lb_404_backend.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.web_backend.self_link
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  project = var.gcp_project
  name    = "${var.lb_name}-http-proxy"
  url_map = google_compute_url_map.http_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  project               = var.gcp_project
  name                  = "${var.lb_name}-http-fr"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  port_range            = tostring(local.http_port)
  ip_address            = google_compute_global_address.lb_ip.address
  target                = google_compute_target_http_proxy.http_proxy.self_link
}
