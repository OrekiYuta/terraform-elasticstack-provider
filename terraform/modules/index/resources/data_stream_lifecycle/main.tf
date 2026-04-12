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
  config     = try(yamldecode(local.raw_config), {})

  managed_index_templates = try(tolist(local.config["managed_index_templates"]), [])
  managed_index_templates_map = {
    for item in local.managed_index_templates :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }

  managed_data_streams = try(tolist(local.config["managed_data_streams"]), [])
  managed_data_streams_map = {
    for item in local.managed_data_streams :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }

  data_stream_lifecycles = try(local.config["data_stream_lifecycles"], [])
  data_stream_lifecycles_map = {
    for item in local.data_stream_lifecycles :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_index_template" "lifecycle_dependency" {
  for_each = local.managed_index_templates_map

  name           = lookup(each.value, "name", null)
  index_patterns = lookup(each.value, "index_patterns", [])
  priority       = lookup(each.value, "priority", null)

  template {
    settings = try(jsonencode(each.value.template.settings), null)
    mappings = try(jsonencode(each.value.template.mappings), null)

    dynamic "alias" {
      for_each = lookup(lookup(each.value, "template", {}), "aliases", [])
      content {
        name = alias.value.name
      }
    }
  }

  dynamic "data_stream" {
    for_each = [1]
    content {}
  }

  version     = lookup(each.value, "version", null)
  composed_of = lookup(each.value, "composed_of", null)
}

resource "elasticstack_elasticsearch_data_stream" "lifecycle_dependency" {
  for_each = local.managed_data_streams_map

  name = lookup(each.value, "name", null)

  depends_on = [elasticstack_elasticsearch_index_template.lifecycle_dependency]
}

resource "elasticstack_elasticsearch_data_stream_lifecycle" "this" {
  for_each = local.data_stream_lifecycles_map

  name = (
    contains(keys(elasticstack_elasticsearch_data_stream.lifecycle_dependency), lookup(each.value, "name", ""))
    ? elasticstack_elasticsearch_data_stream.lifecycle_dependency[lookup(each.value, "name", "")].name
    : lookup(each.value, "name", null)
  )
  enabled          = lookup(each.value, "enabled", null)
  data_retention   = lookup(each.value, "data_retention", null)
  expand_wildcards = lookup(each.value, "expand_wildcards", null)
  downsampling     = lookup(each.value, "downsampling", null)

  depends_on = [elasticstack_elasticsearch_data_stream.lifecycle_dependency]
}

