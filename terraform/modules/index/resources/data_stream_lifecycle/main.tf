terraform {
  required_providers {
	elasticstack = {
	  source  = "elastic/elasticstack"
	  version = "0.14.3"
	}
  }
}

locals {
  raw_config = file("${path.root}/../gitops/index/resources/data_stream_lifecycle.yaml")
  config     = length(trimspace(local.raw_config)) > 0 ? yamldecode(local.raw_config) : {}

  data_stream_lifecycles = try(local.config["data_stream_lifecycles"], [])
  data_stream_lifecycles_map = {
	for item in local.data_stream_lifecycles :
	lookup(item, "name", "") => item
	if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_data_stream_lifecycle" "this" {
  for_each = local.data_stream_lifecycles_map

  name             = lookup(each.value, "name", null)
  enabled          = lookup(each.value, "enabled", null)
  data_retention   = lookup(each.value, "data_retention", null)
  expand_wildcards = lookup(each.value, "expand_wildcards", null)
  downsampling     = lookup(each.value, "downsampling", null)
}

