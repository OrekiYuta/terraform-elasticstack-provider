terraform {
  required_providers {
	elasticstack = {
	  source  = "elastic/elasticstack"
	  version = "0.14.3"
	}
  }
}

locals {
  raw_config = file("${path.root}/../gitops/index/resources/data_stream.yaml")
  config     = length(trimspace(local.raw_config)) > 0 ? yamldecode(local.raw_config) : {}

  data_streams = try(local.config["data_streams"], [])
  data_streams_map = {
	for item in local.data_streams :
	lookup(item, "name", "") => item
	if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_data_stream" "this" {
  for_each = local.data_streams_map

  name = lookup(each.value, "name", null)
}

