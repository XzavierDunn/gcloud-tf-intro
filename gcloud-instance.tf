provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "default-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow-icmp-http" {
  name    = "allow-icmp-http"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "icmp"
  }

  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  source_tags   = ["terraform"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_instance" "nginx_instance" {
  name                    = "nginx-instance"
  machine_type            = "e2-micro"
  zone                    = "us-west1-a"
  tags                    = ["terraform"]
  metadata_startup_script = "sudo apt-get update; sudo apt install nginx -y"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      network_tier = "STANDARD"
    }
  }
}
