terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/security/resources/role.yaml")
  config     = try(yamldecode(local.raw_config), {})

  roles = try(local.config["roles"], [])
  roles_map = {
    for item in local.roles :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_security_role" "this" {
  for_each = local.roles_map

  name     = lookup(each.value, "name", null)
  cluster  = lookup(each.value, "cluster", null)
  run_as   = lookup(each.value, "run_as", null)
  metadata = lookup(each.value, "metadata", null)

  dynamic "indices" {
    for_each = lookup(each.value, "indices", [])
    content {
      names                    = lookup(indices.value, "names", [])
      privileges               = lookup(indices.value, "privileges", [])
      query                    = lookup(indices.value, "query", null)
      allow_restricted_indices = lookup(indices.value, "allow_restricted_indices", null)

      dynamic "field_security" {
        for_each = lookup(indices.value, "field_security", null) != null ? [lookup(indices.value, "field_security", {})] : []
        content {
          grant  = lookup(field_security.value, "grant", null)
          except = lookup(field_security.value, "except", null)
        }
      }
    }
  }

  dynamic "applications" {
    for_each = lookup(each.value, "applications", [])
    content {
      application = lookup(applications.value, "application", null)
      privileges  = lookup(applications.value, "privileges", [])
      resources   = lookup(applications.value, "resources", [])
    }
  }
}

