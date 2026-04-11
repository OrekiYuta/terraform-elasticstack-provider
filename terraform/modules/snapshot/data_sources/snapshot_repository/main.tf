terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/snapshot/data_sources/snapshot_repository.yaml")
  config     = try(yamldecode(local.raw_config), {})

  repositories = try(local.config["repositories"], [])
  repositories_map = {
    for item in local.repositories :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

data "elasticstack_elasticsearch_snapshot_repository" "this" {
  for_each = local.repositories_map
  name     = lookup(each.value, "name", null)
}

output "snapshot_repository_info" {
  value = data.elasticstack_elasticsearch_snapshot_repository.this
}

