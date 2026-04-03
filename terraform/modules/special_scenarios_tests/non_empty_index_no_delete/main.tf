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

  config = yamldecode(file("${path.root}/../gitops/special_scenarios_tests/non_empty_index_no_delete/index.yaml"))
  new_index_names = [for i in lookup(local.config, "indices", []) : i.name]
}


data "external" "check_deleted_indices" {
  program = ["python", "${path.module}/check_deleted_indices.py"]

  query = {
    new_indices = jsonencode(local.new_index_names)
    prefix      = "nte--app1--d0--"
    es_url      = var.es_url
    es_user     = var.es_user
    es_password = var.es_password
  }
}


resource "elasticstack_elasticsearch_index" "this" {
  for_each = { for idx in local.new_index_names : idx => idx }

  name               = each.value
  number_of_shards   = 1
  number_of_replicas = 0

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [data.external.check_deleted_indices]
}