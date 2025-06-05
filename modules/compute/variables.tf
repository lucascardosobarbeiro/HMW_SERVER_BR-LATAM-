variable "instance_name" {
  type        = string
  description = "Nome da instância VM"
}

variable "address_name" {
  type        = string
  description = "Nome do endereço IP estático"
}

variable "subnet_name" {
  type        = string
  description = "Nome da sub-rede onde a VM ficará"
}

variable "zone" {
  type        = string
  description = "Zona GCP para criar a VM"
}

variable "region" {
  type        = string
  description = "Região GCP onde a VM será criada"
}

variable "service_account_email" {
  type        = string
  description = "Service Account associada à VM"
}

variable "tags" {
  type        = list(string)
  description = "Tags associadas à VM para firewall"
}