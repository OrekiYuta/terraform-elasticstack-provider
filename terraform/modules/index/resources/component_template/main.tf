terraform {
  required_providers {
	elasticstack = {
	  source  = "elastic/elasticstack"
	  version = "0.14.3"
	}
  }
}

locals {
  raw_config = file("${path.root}/../gitops/index/resources/component_template.yaml")
  config     = length(trimspace(local.raw_config)) > 0 ? yamldecode(local.raw_config) : {}

  component_templates = try(local.config["component_templates"], [])
  component_templates_map = {
	for item in local.component_templates :
	lookup(item, "name", "") => item
	if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_component_template" "this" {
  for_each = local.component_templates_map

  name    = lookup(each.value, "name", null)
  version = lookup(each.value, "version", null)
  metadata = (
	lookup(each.value, "metadata", null) != null
	? jsonencode(lookup(each.value, "metadata", {}))
	: null
  )

  template {
	settings = (
	  lookup(lookup(each.value, "template", {}), "settings", null) != null
	  ? jsonencode(lookup(lookup(each.value, "template", {}), "settings", {}))
	  : null
	)
	mappings = (
	  lookup(lookup(each.value, "template", {}), "mappings", null) != null
	  ? jsonencode(lookup(lookup(each.value, "template", {}), "mappings", {}))
	  : null
	)

	dynamic "alias" {
	  for_each = lookup(lookup(each.value, "template", {}), "aliases", [])
	  content {
		name           = lookup(alias.value, "name", null)
		filter         = lookup(alias.value, "filter", null)
		is_write_index = lookup(alias.value, "is_write_index", null)
		is_hidden      = lookup(alias.value, "is_hidden", null)
		routing        = lookup(alias.value, "routing", null)
		search_routing = lookup(alias.value, "search_routing", null)
		index_routing  = lookup(alias.value, "index_routing", null)
	  }
	}
  }
}

