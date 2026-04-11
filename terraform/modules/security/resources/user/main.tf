terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/security/resources/user.yaml")
  config     = try(yamldecode(local.raw_config), {})

  users = try(local.config["users"], [])
  users_map = {
    for item in local.users :
    lookup(item, "username", "") => item
    if lookup(item, "username", "") != ""
  }
}

resource "elasticstack_elasticsearch_security_user" "this" {
  for_each = local.users_map

  username      = lookup(each.value, "username", null)
  password      = lookup(each.value, "password", null)
  password_hash = lookup(each.value, "password_hash", null)
  roles         = lookup(each.value, "roles", [])
  full_name     = lookup(each.value, "full_name", null)
  email         = lookup(each.value, "email", null)
  enabled       = lookup(each.value, "enabled", null)
  metadata      = lookup(each.value, "metadata", null)
}

