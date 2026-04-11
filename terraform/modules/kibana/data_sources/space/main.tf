terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/kibana/data_sources/space.yaml")
  config     = try(yamldecode(local.raw_config), {})

  spaces = try(tolist(local.config["spaces"]), [])
  spaces_map = {
    for idx, space in local.spaces :
    tostring(idx) => space
  }
}

data "elasticstack_kibana_spaces" "this" {
  for_each = local.spaces_map
}

output "spaces_info" {
  value = data.elasticstack_kibana_spaces.this
}

