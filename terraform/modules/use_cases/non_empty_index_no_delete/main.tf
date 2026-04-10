terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

variable "es_url" {
  type = string
}

variable "es_user" {
  type = string
}

variable "es_password" {
  type      = string
  sensitive = true
}

locals {
  config = yamldecode(file("${path.root}/../gitops/use_cases/non_empty_index_no_delete/index.yaml"))
  yaml_existing_indices = [for i in lookup(local.config, "indices", []) : i.name]
}


data "external" "custom_validation" {
  program = ["python", "${path.module}/custom_validation.py"]

  query = {
    yaml_existing_indices = jsonencode(local.yaml_existing_indices)
    prefix      = "nte--app1--d0--"
    es_url      = var.es_url
    es_user     = var.es_user
    es_password = var.es_password
  }
}


resource "elasticstack_elasticsearch_index" "this" {
  for_each = { for idx in local.yaml_existing_indices : idx => idx }
  name               = each.value

  depends_on = [data.external.custom_validation]
}