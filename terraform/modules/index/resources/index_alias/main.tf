terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/index/resources/index_alias.yaml")
  config     = try(yamldecode(local.raw_config), {})

  managed_indices = try(tolist(local.config["managed_indices"]), [])
  managed_indices_map = {
    for item in local.managed_indices :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }

  index_aliases = try(local.config["index_aliases"], [])

  index_aliases_normalized = [
    for item in local.index_aliases : merge(item, {
      write_index = (
        lookup(item, "write_index", null) == null
        ? null
        : (
          can(lookup(item, "write_index", null).name)
          ? lookup(item, "write_index", null)
          : { name = tostring(lookup(item, "write_index", null)) }
        )
      )
      read_indices = (
        length(lookup(item, "read_indices", [])) == 0
        ? null
        : [
          for ri in lookup(item, "read_indices", []) : (
            can(ri.name)
            ? ri
            : { name = tostring(ri) }
          )
        ]
      )
    })
  ]

  index_aliases_map = {
    for item in local.index_aliases_normalized :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_index" "alias_dependency" {
  for_each = local.managed_indices_map

  name                = lookup(each.value, "name", null)
  number_of_shards    = lookup(each.value, "number_of_shards", 1)
  number_of_replicas  = lookup(each.value, "number_of_replicas", 0)
  mappings            = lookup(each.value, "mappings", null) != null ? jsonencode(lookup(each.value, "mappings", null)) : null
  deletion_protection = lookup(each.value, "deletion_protection", false)
}

resource "elasticstack_elasticsearch_index_alias" "this" {
  for_each = local.index_aliases_map

  name = lookup(each.value, "name", null)
  write_index = (
    lookup(each.value, "write_index", null) == null
    ? null
    : merge(lookup(each.value, "write_index", {}), {
      name = (
        contains(keys(elasticstack_elasticsearch_index.alias_dependency), lookup(lookup(each.value, "write_index", {}), "name", ""))
        ? elasticstack_elasticsearch_index.alias_dependency[lookup(lookup(each.value, "write_index", {}), "name", "")].name
        : lookup(lookup(each.value, "write_index", {}), "name", null)
      )
    })
  )
  read_indices = (
    lookup(each.value, "read_indices", null) == null
    ? null
    : [
      for ri in lookup(each.value, "read_indices", []) : merge(ri, {
        name = (
          contains(keys(elasticstack_elasticsearch_index.alias_dependency), lookup(ri, "name", ""))
          ? elasticstack_elasticsearch_index.alias_dependency[lookup(ri, "name", "")].name
          : lookup(ri, "name", null)
        )
      })
    ]
  )

  depends_on = [elasticstack_elasticsearch_index.alias_dependency]
}


