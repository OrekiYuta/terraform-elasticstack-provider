terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/kibana/resources/data_view.yaml")
  config     = try(yamldecode(local.raw_config), {})

  data_views = try(local.config["data_views"], [])
  data_views_map = {
    for idx, item in local.data_views :
    tostring(idx) => item
  }
}

resource "elasticstack_kibana_data_view" "this" {
  for_each = local.data_views_map

  data_view = lookup(each.value, "data_view", {})
  space_id  = lookup(each.value, "space_id", null)
  override  = lookup(each.value, "override", null)
}

