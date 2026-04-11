terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/enrich/resources/enrich_policy.yaml")
  config     = try(yamldecode(local.raw_config), {})

  managed_indices = try(tolist(local.config["managed_indices"]), [])
  managed_indices_map = {
    for idx in local.managed_indices :
    lookup(idx, "name", "") => idx
    if lookup(idx, "name", "") != ""
  }

  enrich_policies = try(tolist(local.config["enrich_policies"]), [])
  enrich_policies_map = {
    for policy in local.enrich_policies :
    lookup(policy, "name", "") => policy
    if lookup(policy, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_index" "enrich_dependency" {
  for_each = local.managed_indices_map

  name                = lookup(each.value, "name", null)
  number_of_shards    = lookup(each.value, "number_of_shards", 1)
  number_of_replicas  = lookup(each.value, "number_of_replicas", 0)
  mappings            = lookup(each.value, "mappings", null) != null ? jsonencode(lookup(each.value, "mappings", null)) : null
  deletion_protection = lookup(each.value, "deletion_protection", false)
}

resource "elasticstack_elasticsearch_enrich_policy" "this" {
  for_each = local.enrich_policies_map

  name          = lookup(each.value, "name", null)
  policy_type   = lookup(each.value, "policy_type", "match")
  indices       = [for idx in lookup(each.value, "indices", []) : (contains(keys(elasticstack_elasticsearch_index.enrich_dependency), idx) ? elasticstack_elasticsearch_index.enrich_dependency[idx].name : idx)]
  match_field   = lookup(each.value, "match_field", null)
  enrich_fields = lookup(each.value, "enrich_fields", [])
  query         = lookup(each.value, "query", null) != null ? jsonencode(lookup(each.value, "query", null)) : null

  depends_on = [elasticstack_elasticsearch_index.enrich_dependency]
}

