output "region_1" {
    value = data.google_client_config.region_1.region
}

output "region_2" {
    value = data.google_client_config.region_2.region
}

output "instance_region_1_zone" {
  value = google_compute_instance.vm_region_1.zone
}

output "instance_region_2_zone" {
  value = google_compute_instance.vm_region_2.zone
}
