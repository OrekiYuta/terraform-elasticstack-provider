terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/security/data_sources/user.yaml")
  config     = try(yamldecode(local.raw_config), {})

  users = try(local.config["users"], [])
  users_map = {
    for item in local.users :
    lookup(item, "username", "") => item
    if lookup(item, "username", "") != ""
  }
}

data "elasticstack_elasticsearch_security_user" "this" {
  for_each = local.users_map
  username = lookup(each.value, "username", null)
}

output "user_info" {
  value = data.elasticstack_elasticsearch_security_user.this
}

