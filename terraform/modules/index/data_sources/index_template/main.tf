terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}


locals {
  config = yamldecode(file("${path.root}/../gitops/index/data_sources/index_template.yaml"))
  index_templates = lookup(local.config, "index_templates", [])
  index_templates_map = {
    for tpl in local.index_templates :
    tpl.name => tpl
  }
}


data "elasticstack_elasticsearch_index_template" "this" {
  for_each = local.index_templates_map
  name = each.value.name
}


output "index_template_info" {
  value = data.elasticstack_elasticsearch_index_template.this
}

# Changes to Outputs:
#   + data_sources_index_template_info = {
#       + apm-source-map = {
#           + composed_of                        = []
#           + data_stream                        = null
#           + elasticsearch_connection           = null
#           + id                                 = "-CG7gnTcQOCcKafJxsHMhQ/apm-source-map"
#           + ignore_missing_component_templates = []
#           + index_patterns                     = [
#               + ".apm-source-map",
#             ]
#           + metadata                           = null
#           + name                               = "apm-source-map"
#           + priority                           = 0
#           + template                           = [
#               + {
#                   + alias     = []
#                   + lifecycle = []
#                   + mappings  = jsonencode(
#                         {
#                           + dynamic    = "strict"
#                           + properties = {
#                               + content           = {
#                                   + type = "binary"
#                                 }
#                               + content_sha256    = {
#                                   + type = "keyword"
#                                 }
#                               + created           = {
#                                   + type = "date"
#                                 }
#                               + "file.path"       = {
#                                   + type = "keyword"
#                                 }
#                               + fleet_id          = {
#                                   + type = "keyword"
#                                 }
#                               + "service.name"    = {
#                                   + type = "keyword"
#                                 }
#                               + "service.version" = {
#                                   + type = "keyword"
#                                 }
#                             }
#                         }
#                     )
#                   + settings  = jsonencode(
#                         {
#                           + index = {
#                               + auto_expand_replicas = "0-1"
#                               + hidden               = "true"
#                               + number_of_shards     = "1"
#                             }
#                         }
#                     )
#                 },
#             ]
#           + version                            = 1
#         }
#     }
#
# You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.
