resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
}
output "subnet_name" {
  value       = google_compute_subnetwork.main.name
  description = "Nome da sub-rede criada"
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
    ports    = ["27015", "28960", "27016-27030"]
  }
  allow {
    protocol = "tcp"
    ports    = ["27015", "28960", "27016-27030", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  target_tags   = ["cod-mwr"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}