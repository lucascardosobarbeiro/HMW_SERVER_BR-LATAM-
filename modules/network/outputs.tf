output "subnet_name" {
  value       = google_compute_subnetwork.main.name
  description = "Nome da sub-rede criada pelo módulo"
}

output "network_name" {
  description = "Nome da VPC criada"
  value       = google_compute_network.main.name
}

output "tags" {
  value       = var.tags
  description = "Tags aplicadas à VM e firewall"
}