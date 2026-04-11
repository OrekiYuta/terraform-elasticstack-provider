terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/security/data_sources/role.yaml")
  config     = try(yamldecode(local.raw_config), {})

  roles = try(local.config["roles"], [])
  roles_map = {
    for item in local.roles :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

data "elasticstack_elasticsearch_security_role" "this" {
  for_each = local.roles_map
  name     = lookup(each.value, "name", null)
}

output "role_info" {
  value = data.elasticstack_elasticsearch_security_role.this
}

