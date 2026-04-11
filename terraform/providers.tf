terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

# provider "elasticstack" {
#   elasticsearch {
#     endpoints = [var.es_url]
#     api_key   = var.es_api_key
#   }
# }


provider "elasticstack" {
  elasticsearch {
    endpoints = [var.es_url]
    username  = var.es_user
    password  = var.es_password
  }

  kibana {
    endpoints = [var.kibana_url]
    username  = var.kibana_user
    password  = var.kibana_password
  }
}