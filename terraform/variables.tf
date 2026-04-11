variable "es_url" {
  type = string
}

variable "es_api_key" {
  type      = string
  sensitive = true
}

variable "es_user" {
  type = string
}

variable "es_password" {
  type      = string
  sensitive = true
}

variable "kibana_url" {
  type = string
}

variable "kibana_user" {
  type = string
}

variable "kibana_password" {
  type      = string
  sensitive = true
}