terraform {
  required_providers {
	elasticstack = {
	  source  = "elastic/elasticstack"
	  version = "0.14.3"
	}
  }
}

locals {
  raw_config = file("${path.root}/../gitops/index/resources/index_alias.yaml")
  config     = length(trimspace(local.raw_config)) > 0 ? yamldecode(local.raw_config) : {}

  index_aliases = try(local.config["index_aliases"], [])
  index_aliases_map = {
	for item in local.index_aliases :
	lookup(item, "name", "") => item
	if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_index_alias" "this" {
  for_each = local.index_aliases_map

  name         = lookup(each.value, "name", null)
  write_index  = lookup(each.value, "write_index", null)
  read_indices = lookup(each.value, "read_indices", null)
}

