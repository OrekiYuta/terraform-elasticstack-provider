terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
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

variable "prefix" {
  type    = string
  default = "http--nte--app1--d0--"
}

locals {
  config                = yamldecode(file("${path.root}/../gitops/use_cases/http_non_empty_index_no_delete/index.yaml"))
  yaml_existing_indices = [for i in lookup(local.config, "indices", []) : i.name]

  request_headers = {
    Accept        = "application/json"
    Authorization = "Basic ${base64encode(format("%s:%s", var.es_user, var.es_password))}"
  }
}

# Query all existing indices with the target prefix from Elasticsearch.
data "http" "existing_indices" {
  url             = "${trimsuffix(var.es_url, "/")}/_cat/indices/${var.prefix}*?h=index&format=json"
  request_headers = local.request_headers
}

locals {
  es_existing_indices = [
    for row in try(jsondecode(data.http.existing_indices.response_body), []) :
    tostring(lookup(row, "index", "")) if trimspace(tostring(lookup(row, "index", ""))) != ""
  ]

  indices_to_delete = setsubtract(toset(local.es_existing_indices), toset(local.yaml_existing_indices))
}

# Query document count for each index Terraform would implicitly delete (present in ES, absent from YAML).
data "http" "index_count" {
  for_each = local.indices_to_delete

  url             = "${trimsuffix(var.es_url, "/")}/${each.value}/_count"
  request_headers = local.request_headers
}

locals {
  index_doc_counts = {
    for idx, resp in data.http.index_count :
    idx => (resp.status_code == 404 ? 0 : tonumber(lookup(try(jsondecode(resp.response_body), {}), "count", 0)))
  }

  non_empty_indices = [for idx, count in local.index_doc_counts : idx if count > 0]

  non_empty_with_counts = [
    for idx in local.non_empty_indices :
    format("%s(%d docs)", idx, local.index_doc_counts[idx])
  ]
}

resource "terraform_data" "validation_gate" {
  lifecycle {
    precondition {
      condition     = data.http.existing_indices.status_code == 200
      error_message = "Failed to query existing indices via HTTP, status_code=${data.http.existing_indices.status_code}."
    }

    precondition {
      condition     = alltrue([for _, resp in data.http.index_count : contains([200, 404], resp.status_code)])
      error_message = "Failed to query one or more index _count endpoints via HTTP."
    }

    precondition {
      condition     = length(local.non_empty_indices) == 0
      error_message = "Cannot continue. Non-empty indices would be deleted: ${join(", ", local.non_empty_with_counts)}."
    }
  }
}

resource "elasticstack_elasticsearch_index" "this" {
  for_each = { for idx in local.yaml_existing_indices : idx => idx }
  name = each.value
  deletion_protection = false
  depends_on = [terraform_data.validation_gate]
}

output "http_non_empty_index_no_delete" {
  value = {
    yaml_existing_indices = local.yaml_existing_indices
    es_existing_indices   = local.es_existing_indices
    indices_to_delete     = local.indices_to_delete
    index_doc_counts      = local.index_doc_counts
    non_empty_indices     = local.non_empty_indices
  }
}

