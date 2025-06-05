variable "network_name" {
  type        = string
  description = "Nome da VPC a ser criada"
}

variable "subnet_name" {
  type        = string
  description = "Nome da sub-rede a ser criada"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR para a sub-rede (ex.: 10.10.0.0/24)"
}

variable "region" {
  type        = string
  description = "Região para criar a sub-rede"
}

/*variable "allowed_admin_ips" {
  type        = list(string)
  description = "Lista de IPs autorizados a acessar RDP"
}*/

variable "game_port" {
  type        = number
  description = "Porta principal do jogo (ex.: 28960)"
  default     = 28960
}

variable "extra_udp_ports" {
  type        = list(string)
  description = "Portas UDP adicionais para o jogo"
  default     = ["27015", "27016-27030"]
}

variable "extra_tcp_ports" {
  type        = list(string)
  description = "Portas TCP adicionais para o jogo"
  default     = ["27015", "27016-27030"]
}

variable "tags" {
  type        = list(string)
  description = "Tags aplicadas aos recursos (VM) para firewall"
  default     = ["cod-mwr"]
}