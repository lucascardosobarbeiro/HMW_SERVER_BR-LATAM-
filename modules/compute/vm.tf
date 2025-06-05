data "google_compute_image" "windows" {
  family  = "windows-2019"
  project = "windows-cloud"
}

resource "google_compute_address" "static_ip" {
  name   = var.address_name
  region = var.region
}

resource "google_compute_instance" "cod_mwr_server" {
  name         = var.instance_name
  machine_type = "n2-standard-4"
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.windows.self_link
      size  = 200
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork   = var.subnet_name
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

 metadata = {
    "startup-script-ps1" = file("${path.module}/../../environments/default/infra/scripts/startup.ps1")
  }

  service_account {
    email  = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  depends_on = [google_compute_address.static_ip]
}

output "static_ip_address" {
  description = "Endereço IP estático da VM"
  value       = google_compute_address.static_ip.address
}