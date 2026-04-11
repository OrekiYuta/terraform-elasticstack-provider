terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/kibana/resources/import_saved_objects.yaml")
  config     = try(yamldecode(local.raw_config), {})

  imports = try(tolist(local.config["imports"]), [])
  imports_map = {
    for idx, item in local.imports :
    tostring(idx) => item
  }
}

resource "elasticstack_kibana_import_saved_objects" "this" {
  for_each = local.imports_map

  file_contents = lookup(each.value, "file_contents", null) != null ? lookup(each.value, "file_contents", null) : file("${path.root}/../${lookup(each.value, "file_path", "")}")

  space_id             = lookup(each.value, "space_id", null)
  overwrite            = lookup(each.value, "overwrite", null)
  ignore_import_errors = lookup(each.value, "ignore_import_errors", null)
}

