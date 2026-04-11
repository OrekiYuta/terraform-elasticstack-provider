terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/security/resources/role_mapping.yaml")
  config     = try(yamldecode(local.raw_config), {})

  role_mappings = try(local.config["role_mappings"], [])
  role_mappings_map = {
    for item in local.role_mappings :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_security_role_mapping" "this" {
  for_each = local.role_mappings_map

  name     = lookup(each.value, "name", null)
  enabled  = lookup(each.value, "enabled", null)
  roles    = lookup(each.value, "roles", [])
  rules    = lookup(each.value, "rules", null) != null ? jsonencode(lookup(each.value, "rules", null)) : null
  metadata = lookup(each.value, "metadata", null)
}

