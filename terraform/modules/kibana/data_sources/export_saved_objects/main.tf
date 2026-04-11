terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/kibana/data_sources/export_saved_objects.yaml")
  config     = try(yamldecode(local.raw_config), {})

  exports = try(tolist(local.config["exports"]), [])
  exports_map = {
    for idx, item in local.exports :
    tostring(idx) => item
  }
}

data "elasticstack_kibana_export_saved_objects" "this" {
  for_each = local.exports_map

  objects                 = lookup(each.value, "objects", [])
  space_id                = lookup(each.value, "space_id", null)
  include_references_deep = lookup(each.value, "include_references_deep", null)
  exclude_export_details  = lookup(each.value, "exclude_export_details", null)
}

output "export_saved_objects_info" {
  value = data.elasticstack_kibana_export_saved_objects.this
}

