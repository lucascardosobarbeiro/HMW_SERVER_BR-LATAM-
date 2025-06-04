provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "network" {
  source           = "../../modules/network"
  region           = var.region
  subnet_name      = "hmw-subnet"
  subnet_cidr      = "10.10.0.0/24"
  network_name     = "hmw-network"
  allowed_admin_ips = var.allowed_admin_ips
}

module "compute" {
  source                = "../../modules/compute"
  instance_name         = var.instance_name
  address_name          = var.address_name
  subnet_name           = module.network.subnet_name
  zone                  = var.zone
  region                = var.region
  service_account_email = var.service_account_email
}


resource "google_monitoring_notification_channel" "email_alert" {
  project      = var.project_id
  type         = "email"
  display_name = "Admin Email Alerts"
  labels = {
    email_address = var.alert_email
  }
}