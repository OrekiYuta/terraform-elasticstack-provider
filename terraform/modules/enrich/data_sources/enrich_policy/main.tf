terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/enrich/data_sources/enrich_policy.yaml")
  config     = try(yamldecode(local.raw_config), {})

  enrich_policies = try(tolist(local.config["enrich_policies"]), [])
  enrich_policies_map = {
    for policy in local.enrich_policies :
    lookup(policy, "name", "") => policy
    if lookup(policy, "name", "") != ""
  }
}

data "elasticstack_elasticsearch_enrich_policy" "this" {
  for_each = local.enrich_policies_map
  name     = lookup(each.value, "name", null)
}

output "enrich_policy_info" {
  value = data.elasticstack_elasticsearch_enrich_policy.this
}

