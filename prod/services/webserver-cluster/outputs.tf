# output "load_balancer_ip" {
#   value = google_compute_global_address.web_ip.address
# }

output "db_username" {
  value     = var.db_username
  sensitive = true
}

output "db_password" {
  value     = var.db_password
  sensitive = true
}

output "db_name" {
  value = var.db_name
}