provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "network" {
  source       = "../../modules/network"
  region       = var.region
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  network_name = var.network_name
  //allowed_admin_ips = var.allowed_admin_ips
  game_port       = var.game_port
  extra_udp_ports = var.extra_udp_ports
  extra_tcp_ports = var.extra_tcp_ports
  tags            = var.tags
}

module "compute" {
  source                = "../../modules/compute"
  instance_name         = var.instance_name
  address_name          = var.address_name
  subnet_name           = module.network.subnet_name
  zone                  = var.zone
  region                = var.region
  service_account_email = var.service_account_email
  tags                  = module.network.tags // ou var.tags, se preferir
}

resource "google_monitoring_notification_channel" "email_alert" {
  project      = var.project_id
  type         = "email"
  display_name = "Admin Email Alerts"
  labels = {
    email_address = var.alert_email
  }
}

output "server_static_ip" {
  description = "IP estático do servidor COD MWR"
  value       = module.compute.static_ip_address
}