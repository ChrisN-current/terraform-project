###############################################################################
# Remote state (DB) - GCS backend equivalent of S3
###############################################################################

data "terraform_remote_state" "db" {
  backend = "gcs"

  config = {
    bucket = var.db_remote_state_bucket
    prefix = var.db_remote_state_key
  }
}

# MIG

module "mig" {
  source = "../clusters/mig-rolling-deploy/web_mig"

  cluster_name = "hello-world-${var.environment}"

  gcp_project  = var.gcp_project
  zone         = var.zone

  source_image = var.ami
  machine_type = var.instance_type

  server_port = var.server_port

  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  })

  min_replicas       = var.min_size
  max_replicas       = var.max_size
  enable_autoscaling = var.enable_autoscaling

  custom_tags = var.custom_tags

  network    = var.network
  subnetwork = var.subnetwork
}

# HTTP Load Balancer 

module "lb" {
  source = "../networking/http-lb" 
  cluster_name = "hello-world-${var.environment}"
  gcp_project = var.gcp_project
  lb_name     = "hello-world-${var.environment}"
  target_size = 2

  # Attach LB backend to MIG
  zone                = var.zone
  server_port = var.server_port

}

########### Remote exec provisioner ##############

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.region
  zone    = var.zone
}

# 1) Equivalent of security group allowing SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name}-allow-ssh"
  network = var.network

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges

  # Equivalent to "attach SG to instance": use tags
  target_tags = ["${var.name}-ssh"]
}

# 2) Generate SSH keypair (same tls provider)
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 3) GCE VM (equivalent of aws_instance)
resource "google_compute_instance" "example" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["${var.name}-ssh"]

  boot_disk {
    initialize_params {
      # Equivalent of picking an AMI: Debian 11 family
      image = "projects/debian-cloud/global/images/family/debian-11"
    }
  }

  network_interface {
    network = var.network

    # Public IP (like self.public_ip)
    access_config {}
  }

  # 4) Equivalent of aws_key_pair: put public key into instance metadata
  # Format: "username:ssh-rsa AAAA..."
  metadata = {
    ssh-keys = "${var.ssh_user}:${tls_private_key.example.public_key_openssh}"
  }

  # 5) Equivalent of remote-exec provisioner
  provisioner "remote-exec" {
    inline = [
      "echo \"hello, world from $(uname -smp)\""
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[0].access_config[0].nat_ip
      user        = var.ssh_user
      private_key = tls_private_key.example.private_key_pem
    }
  }
}

output "public_ip" {
  value = google_compute_instance.example.network_interface[0].access_config[0].nat_ip
}
