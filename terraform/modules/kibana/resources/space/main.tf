terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/kibana/resources/space.yaml")
  config     = try(yamldecode(local.raw_config), {})

  spaces = try(tolist(local.config["spaces"]), [])
  spaces_map = {
    for idx, space in local.spaces :
    lookup(space, "space_id", tostring(idx)) => space
  }
}

resource "elasticstack_kibana_space" "this" {
  for_each = local.spaces_map

  space_id          = lookup(each.value, "space_id", null)
  name              = lookup(each.value, "name", null)
  description       = lookup(each.value, "description", null)
  color             = lookup(each.value, "color", null)
  initials          = lookup(each.value, "initials", null)
  image_url         = lookup(each.value, "image_url", null)
  disabled_features = lookup(each.value, "disabled_features", null)
  solution          = lookup(each.value, "solution", null)
}

