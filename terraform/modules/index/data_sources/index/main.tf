terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}


locals {
  config = yamldecode(file("${path.root}/../gitops/index/data_sources/index.yaml"))
  indices = lookup(local.config, "indices", [])
  indices_map = {
    for idx in local.indices :
    idx.name => idx
  }
}


data "elasticstack_elasticsearch_indices" "this" {
  for_each = local.indices_map
  target = each.value.name
}


output "index_info" {
  value = flatten([
    for ds in data.elasticstack_elasticsearch_indices.this :
    [for idx in ds.indices : idx.name]
  ])
}


# Changes to Outputs:
#   + data_sources_index_info = [
#       + "application-metrics-kafka-new",
#       + "application-metrics-openshift",
#       + "application-metrics-gitlab-security",
#       + "application-metrics-seeker",
#       + "application-metrics-servicenow",
#       + "application-metrics-gitlab",
#       + "application-metrics-jenkins",
#       + "application-metrics-jenkins-resource-optimization-openshift",
#       + "application-metrics-jenkins-security",
#       + "application-metrics-kafka",
#       + "application-metrics-openshift-security",
#       + "application-metrics-snyk",
#       + "application-metrics-jenkins-resource-optimization",
#       + "application-metrics-kong",
#       + "application-metrics-resource-optimization-database",
#     ]


# Changes to Outputs:
#   + index_info = [
#       + {
#           + alias                                  = []
#           + analysis_analyzer                      = null
#           + analysis_char_filter                   = null
#           + analysis_filter                        = null
#           + analysis_normalizer                    = null
#           + analysis_tokenizer                     = null
#           + analyze_max_token_count                = null
#           + auto_expand_replicas                   = null
#           + blocks_metadata                        = null
#           + blocks_read                            = null
#           + blocks_read_only                       = null
#           + blocks_read_only_allow_delete          = null
#           + blocks_write                           = null
#           + codec                                  = null
#           + default_pipeline                       = null
#           + deletion_protection                    = null
#           + final_pipeline                         = null
#           + gc_deletes                             = null
#           + highlight_max_analyzed_offset          = null
#           + id                                     = null
#           + indexing_slowlog_level                 = null
#           + indexing_slowlog_source                = null
#           + indexing_slowlog_threshold_index_debug = null
#           + indexing_slowlog_threshold_index_info  = null
#           + indexing_slowlog_threshold_index_trace = null
#           + indexing_slowlog_threshold_index_warn  = null
#           + load_fixed_bitset_filters_eagerly      = null
#           + mapping_coerce                         = null
#           + mappings                               = jsonencode(
#                 {
#                   + dynamic    = "strict"
#                   + properties = {
#                       + "@timestamp" = {
#                           + type = "date"
#                         }
#                       + app_id       = {
#                           + type = "keyword"
#                         }
#                       + app_name     = {
#                           + type = "keyword"
#                         }
#                       + cluster      = {
#                           + type = "keyword"
#                         }
#                       + environment  = {
#                           + type = "keyword"
#                         }
#                       + job_name     = {
#                           + type = "keyword"
#                         }
#                       + job_result   = {
#                           + type = "keyword"
#                         }
#                       + microservice = {
#                           + type = "keyword"
#                         }
#                       + month        = {
#                           + type = "keyword"
#                         }
#                       + pvt          = {
#                           + type = "keyword"
#                         }
#                       + year         = {
#                           + type = "keyword"
#                         }
#                     }
#                 }
#             )
#           + master_timeout                         = null
#           + max_docvalue_fields_search             = null
#           + max_inner_result_window                = null
#           + max_ngram_diff                         = null
#           + max_refresh_listeners                  = null
#           + max_regex_length                       = null
#           + max_rescore_window                     = null
#           + max_result_window                      = null
#           + max_script_fields                      = null
#           + max_shingle_diff                       = null
#           + max_terms_count                        = null
#           + name                                   = "application-metrics-jenkins"
#           + number_of_replicas                     = 1
#           + number_of_routing_shards               = null
#           + number_of_shards                       = 1
#           + query_default_field                    = []
#           + refresh_interval                       = null
#           + routing_allocation_enable              = null
#           + routing_partition_size                 = null
#           + routing_rebalance_enable               = null
#           + search_idle_after                      = null
#           + search_slowlog_level                   = null
#           + search_slowlog_threshold_fetch_debug   = null
#           + search_slowlog_threshold_fetch_info    = null
#           + search_slowlog_threshold_fetch_trace   = null
#           + search_slowlog_threshold_fetch_warn    = null
#           + search_slowlog_threshold_query_debug   = null
#           + search_slowlog_threshold_query_info    = null
#           + search_slowlog_threshold_query_trace   = null
#           + search_slowlog_threshold_query_warn    = null
#           + settings_raw                           = jsonencode(
#                 {
#                   + "index.creation_date"                               = "1743479553132"
#                   + "index.number_of_replicas"                          = "1"
#                   + "index.number_of_shards"                            = "1"
#                   + "index.provided_name"                               = "application-metrics-jenkins"
#           + unassigned_node_left_delayed_timeout   = null
#           + wait_for_active_shards                 = null
#         },
#     ]
