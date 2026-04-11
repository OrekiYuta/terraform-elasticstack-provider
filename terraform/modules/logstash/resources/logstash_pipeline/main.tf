terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/logstash/resources/logstash_pipeline.yaml")
  config     = try(yamldecode(local.raw_config), {})

  pipelines = try(local.config["pipelines"], [])
  pipelines_map = {
    for idx, item in local.pipelines :
    lookup(item, "pipeline_id", tostring(idx)) => item
  }
}

resource "elasticstack_elasticsearch_logstash_pipeline" "this" {
  for_each = local.pipelines_map

  pipeline_id = lookup(each.value, "pipeline_id", null)
  description = lookup(each.value, "description", null)
  pipeline    = lookup(each.value, "pipeline", null)

  pipeline_metadata = lookup(each.value, "pipeline_metadata", null) == null ? null : (
    can(regex(".*", lookup(each.value, "pipeline_metadata", null)))
    ? lookup(each.value, "pipeline_metadata", null)
    : jsonencode(lookup(each.value, "pipeline_metadata", null))
  )

  pipeline_batch_delay         = lookup(each.value, "pipeline_batch_delay", null)
  pipeline_batch_size          = lookup(each.value, "pipeline_batch_size", null)
  pipeline_ecs_compatibility   = lookup(each.value, "pipeline_ecs_compatibility", null)
  pipeline_ordered             = lookup(each.value, "pipeline_ordered", null)
  pipeline_plugin_classloaders = lookup(each.value, "pipeline_plugin_classloaders", null)
  pipeline_unsafe_shutdown     = lookup(each.value, "pipeline_unsafe_shutdown", null)
  pipeline_workers             = lookup(each.value, "pipeline_workers", null)

  queue_checkpoint_acks   = lookup(each.value, "queue_checkpoint_acks", null)
  queue_checkpoint_retry  = lookup(each.value, "queue_checkpoint_retry", null)
  queue_checkpoint_writes = lookup(each.value, "queue_checkpoint_writes", null)
  queue_drain             = lookup(each.value, "queue_drain", null)
  queue_max_bytes         = lookup(each.value, "queue_max_bytes", null)
  queue_max_events        = lookup(each.value, "queue_max_events", null)
  queue_page_capacity     = lookup(each.value, "queue_page_capacity", null)
  queue_type              = lookup(each.value, "queue_type", null)
}

