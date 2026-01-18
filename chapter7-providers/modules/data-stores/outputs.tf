output "public_ip_address" {
  value       = google_sql_database_instance.example.public_ip_address
  description = "Connect to the database at this public endpoint"
}

output "private_ip_address" {
  value       = google_sql_database_instance.example.private_ip_address
  description = "Connect to the database at this private endpoint"
}

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
