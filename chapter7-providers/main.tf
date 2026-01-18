data "google_client_config" "region_1" {
    provider = google.region_1
}

data "google_client_config" "region_2" {
    provider = google.region_2
}

data "google_compute_image" "ubuntu_region_1" {
  provider = google
  family   = "debian-11"
  project  = "debian-cloud"
}

data "google_compute_image" "ubuntu_region_2" {
  provider = google
  family   = "debian-11"
  project  = "debian-cloud"
}

resource "google_compute_instance" "vm_region_1" {
  provider    = google.region_1
  name        = "example-vm-region-1"
  machine_type = "e2-medium"
  zone        = "${data.google_client_config.region_1.region}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_region_1.self_link
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_instance" "vm_region_2" {
  provider    = google.region_2
  name        = "example-vm-region-2"
  machine_type = "e2-medium"
  zone        = "${data.google_client_config.region_2.region}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_region_2.self_link
    }
  }

  network_interface {
    network = "default"
  }
}






