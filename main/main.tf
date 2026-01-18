# module "networking" {
#   source       = "../Networking"
# }


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
#     nohup python3 -m http.server 8080 > /var/log/webserver.log 2>&1 &
#   EOF

#   labels = {
#     name = "terraform-example"
#   }

#   metadata = {
#     startup-script-change-trigger = "v3"  # manually bump to force startup script rerun
#   }

#   depends_on = [module.networking]
# }
