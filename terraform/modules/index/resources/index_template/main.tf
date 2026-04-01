terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {

  raw_config = file("${path.root}/../gitops/index/resources/index_template.yaml")
  config     = length(trimspace(local.raw_config)) > 0 ? yamldecode(local.raw_config) : {}

  templates     = try(local.config.index_templates, [])
  templates_map = { for t in local.templates : t.name => t }
}

resource "elasticstack_elasticsearch_index_template" "this" {
  for_each = local.templates_map

  name           = each.value.name
  index_patterns = lookup(each.value, "index_patterns", [])
  priority       = lookup(each.value, "priority", null)


  template {
    settings = try(jsonencode(each.value.template.settings), null)
    mappings = try(jsonencode(each.value.template.mappings), null)


    dynamic "alias" {
      for_each = lookup(each.value.template, "aliases", [])
      content {
        name = alias.value.name
      }
    }
  }


  dynamic "data_stream" {
    for_each = lookup(each.value, "data_stream", false) ? [1] : []
    content {}
  }


  version     = lookup(each.value, "version", null)
  composed_of = lookup(each.value, "composed_of", null)
}