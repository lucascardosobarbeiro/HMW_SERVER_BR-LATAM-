variable "project_id" {
  default = "projeto-server-cod"
}

variable "region" {
  default = "southamerica-east1"
}

variable "zone" {
  default = "southamerica-east1-a"
}

variable "instance_name" {
  default = "cod-mwr-server"
}

variable "address_name" {
  default = "cod-mwr-static-ip"
}

variable "service_account_email" {
  default = "default"
}

variable "allowed_admin_ips" {
  type    = list(string)
  default = ["SEU_IP_PUBLICO/32"]
}

variable "alert_email" {
  default = "lcb.barbeiro@gmail.com"
}