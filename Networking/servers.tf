# resource "google_compute_instance" "example" {
#   name         = "example-instance"
#   machine_type = "e2-micro"
#   zone         = "us-east1-b"

#   tags = ["web", "allow-8080"]

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-12"
#     }
#   }

#   network_interface {
#     network = "default"

#     access_config {
#       # This assigns a public IP
#     }
#   }

#   metadata_startup_script = <<-EOF
#     #!/bin/bash
#     set -euxo pipefail
#     mkdir -p /var/www/html
#     echo "Hello, World!" > /var/www/html/index.html
#     cd /var/www/html
#     nohup python3 -m http.server ${var.server_port[0]} > /var/log/webserver.log 2>&1 &
#   EOF

#   labels = {
#     name = "terraform-example"
#   }

#   metadata = {
#     startup-script-change-trigger = "v3"  # manually bump to force startup script rerun
#   }
# }

# resource "google_compute_instance_template" "example" {
#   name         = "terraform-template-example"
#   machine_type = "e2-micro"

#   disk {
#     source_image = "debian-cloud/debian-11"
#     auto_delete  = true
#     boot         = true
#   }

#   network_interface {
#     network = "default"
#     access_config {} # enables external IP
#   }

#   labels = {
#     name = "terraform-asg-example"
#   }

#   metadata = {
#     foo = "bar"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "google_compute_instance_group_manager" "example" {
#   name               = "terraform-igm-example"
#   base_instance_name = "terraform-igm"
#   version {
#     instance_template = google_compute_instance_template.example.id
#   }

#   target_size = 2 # like desired_capacity (AWS needs min+max+desired, GCP sets separately)
#   zone        = "us-central1-a"
# }

# resource "google_compute_autoscaler" "example" {
#   name   = "terraform-autoscaler-example"
#   target = google_compute_instance_group_manager.example.id
#   zone   = "us-central1-a"

#   autoscaling_policy {
#     min_replicas = 2
#     max_replicas = 10

#     cpu_utilization {
#       target = 0.6 # scale when avg CPU > 60%
#     }
#   }
# }
