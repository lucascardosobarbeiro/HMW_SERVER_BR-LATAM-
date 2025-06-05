resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id
}

resource "google_compute_firewall" "allow_game_ports" {
  name    = "allow-game-ports"
  network = google_compute_network.main.name

  allow {
    protocol = "udp"
    ports    = [var.game_port]      // 28960
  }
  allow {
    protocol = "udp"
    ports    = var.extra_udp_ports  // 27015, 27016-27030
  }
  allow {
    protocol = "tcp"
    ports    = var.extra_tcp_ports  // 27015, 27016-27030
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  target_tags   = var.tags

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
/*
resource "google_compute_firewall" "allow_rdp_admin" {
  name    = "allow-rdp-admin"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  /*source_ranges = var.allowed_admin_ips
  direction     = "INGRESS"
  target_tags   = var.tags

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
} */