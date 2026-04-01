terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {

  config = yamldecode(file("${path.root}/../gitops/index/resources/index.yaml"))

  indices = lookup(local.config, "indices", [])

  indices_map = {
    for idx in local.indices :
    idx.name => idx
  }
}

resource "elasticstack_elasticsearch_index" "this" {

  for_each = local.indices_map

  name = each.value.name

  number_of_shards   = lookup(each.value, "number_of_shards", 1)
  number_of_replicas = lookup(each.value, "number_of_replicas", 0)


  alias = [
    for a in lookup(each.value, "aliases", []) : {
      name         = a.name
      filter       = lookup(a, "filter", null)
      is_write_index = lookup(a, "is_write_index", null)
      is_hidden      = lookup(a, "is_hidden", null)
      routing        = lookup(a, "routing", null)
      search_routing = lookup(a, "search_routing", null)
      index_routing  = lookup(a, "index_routing", null)
    }
  ]

  mappings = lookup(each.value, "mappings", null) != null ? jsonencode(each.value.mappings) : null

  deletion_protection = lookup(each.value, "deletion_protection", false)
}