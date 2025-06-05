variable "project_id" {
  type        = string
  description = "ID do projeto GCP"
}

variable "region" {
  type        = string
  description = "Região GCP"
}

variable "zone" {
  type        = string
  description = "Zona GCP"
}

variable "network_name" {
  type        = string
  description = "Nome da VPC para a rede"
}

variable "subnet_name" {
  type        = string
  description = "Nome da sub-rede para a VM"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR da sub-rede"
}

/*variable "allowed_admin_ips" {
  type        = list(string)
  description = "IPs permitidos para RDP"
}*/

variable "game_port" {
  type        = number
  description = "Porta UDP principal do jogo"
  default     = 28960
}

variable "extra_udp_ports" {
  type        = list(string)
  description = "Portas UDP adicionais do jogo"
  default     = ["27015", "27016-27030"]
}

variable "extra_tcp_ports" {
  type        = list(string)
  description = "Portas TCP adicionais do jogo"
  default     = ["27015", "27016-27030"]
}

variable "tags" {
  type        = list(string)
  description = "Tags aplicadas à VM e firewall"
  default     = ["cod-mwr"]
}

variable "instance_name" {
  type        = string
  description = "Nome da instância VM"
}

variable "address_name" {
  type        = string
  description = "Nome do endereço IP estático"
}

variable "service_account_email" {
  type        = string
  description = "Service Account para a VM"
}

variable "alert_email" {
  type        = string
  description = "E-mail para alertas"
}