output "mig_name" {
  value = google_compute_instance_group_manager.web_mig.name
}

output "health_check_self_link" {
  value = google_compute_health_check.web_hc.self_link
}
