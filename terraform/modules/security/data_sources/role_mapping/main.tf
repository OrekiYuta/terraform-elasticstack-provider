terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/security/data_sources/role_mapping.yaml")
  config     = try(yamldecode(local.raw_config), {})

  role_mappings = try(local.config["role_mappings"], [])
  role_mappings_map = {
    for item in local.role_mappings :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

data "elasticstack_elasticsearch_security_role_mapping" "this" {
  for_each = local.role_mappings_map
  name     = lookup(each.value, "name", null)
}

output "role_mapping_info" {
  value = data.elasticstack_elasticsearch_security_role_mapping.this
}

