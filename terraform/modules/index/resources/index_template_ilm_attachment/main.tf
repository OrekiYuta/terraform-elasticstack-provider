terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/index/resources/index_template_ilm_attachment.yaml")
  config     = try(yamldecode(local.raw_config), {})

  managed_index_lifecycles = try(tolist(local.config["managed_index_lifecycles"]), [])
  managed_index_lifecycles_map = {
    for item in local.managed_index_lifecycles :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }

  managed_index_templates = try(tolist(local.config["managed_index_templates"]), [])
  managed_index_templates_map = {
    for item in local.managed_index_templates :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }

  index_template_ilm_attachments = try(local.config["index_template_ilm_attachments"], [])
  index_template_ilm_attachments_map = {
    for item in local.index_template_ilm_attachments :
    "${lookup(item, "index_template", "")}::${lookup(item, "lifecycle_name", "")}" => item
    if lookup(item, "index_template", "") != "" && lookup(item, "lifecycle_name", "") != ""
  }
}

resource "elasticstack_elasticsearch_index_lifecycle" "managed" {
  for_each = local.managed_index_lifecycles_map

  name = lookup(each.value, "name", null)
  metadata = (
    lookup(each.value, "metadata", null) != null
    ? jsonencode(lookup(each.value, "metadata", {}))
    : null
  )

  dynamic "hot" {
    for_each = lookup(each.value, "hot", null) != null ? [lookup(each.value, "hot", {})] : []
    content {
      min_age = lookup(hot.value, "min_age", null)

      dynamic "downsample" {
        for_each = lookup(hot.value, "downsample", null) != null ? [lookup(hot.value, "downsample", {})] : []
        content {
          fixed_interval = lookup(downsample.value, "fixed_interval", null)
          wait_timeout   = lookup(downsample.value, "wait_timeout", null)
        }
      }

      dynamic "forcemerge" {
        for_each = lookup(hot.value, "forcemerge", null) != null ? [lookup(hot.value, "forcemerge", {})] : []
        content {
          index_codec      = lookup(forcemerge.value, "index_codec", null)
          max_num_segments = lookup(forcemerge.value, "max_num_segments", null)
        }
      }

      dynamic "readonly" {
        for_each = lookup(hot.value, "readonly", null) != null ? [lookup(hot.value, "readonly", {})] : []
        content {
          enabled = lookup(readonly.value, "enabled", null)
        }
      }

      dynamic "rollover" {
        for_each = lookup(hot.value, "rollover", null) != null ? [lookup(hot.value, "rollover", {})] : []
        content {
          max_age                = lookup(rollover.value, "max_age", null)
          max_docs               = lookup(rollover.value, "max_docs", null)
          max_primary_shard_docs = lookup(rollover.value, "max_primary_shard_docs", null)
          max_primary_shard_size = lookup(rollover.value, "max_primary_shard_size", null)
          max_size               = lookup(rollover.value, "max_size", null)
          min_age                = lookup(rollover.value, "min_age", null)
          min_docs               = lookup(rollover.value, "min_docs", null)
          min_primary_shard_docs = lookup(rollover.value, "min_primary_shard_docs", null)
          min_primary_shard_size = lookup(rollover.value, "min_primary_shard_size", null)
          min_size               = lookup(rollover.value, "min_size", null)
        }
      }

      dynamic "searchable_snapshot" {
        for_each = lookup(hot.value, "searchable_snapshot", null) != null ? [lookup(hot.value, "searchable_snapshot", {})] : []
        content {
          force_merge_index  = lookup(searchable_snapshot.value, "force_merge_index", null)
          snapshot_repository = lookup(searchable_snapshot.value, "snapshot_repository", null)
        }
      }

      dynamic "set_priority" {
        for_each = lookup(hot.value, "set_priority", null) != null ? [lookup(hot.value, "set_priority", {})] : []
        content {
          priority = lookup(set_priority.value, "priority", null)
        }
      }

      dynamic "shrink" {
        for_each = lookup(hot.value, "shrink", null) != null ? [lookup(hot.value, "shrink", {})] : []
        content {
          allow_write_after_shrink = lookup(shrink.value, "allow_write_after_shrink", null)
          max_primary_shard_size   = lookup(shrink.value, "max_primary_shard_size", null)
          number_of_shards         = lookup(shrink.value, "number_of_shards", null)
        }
      }

      dynamic "unfollow" {
        for_each = lookup(hot.value, "unfollow", null) != null ? [lookup(hot.value, "unfollow", {})] : []
        content {
          enabled = lookup(unfollow.value, "enabled", null)
        }
      }
    }
  }

  dynamic "delete" {
    for_each = lookup(each.value, "delete", null) != null ? [lookup(each.value, "delete", {})] : []
    content {
      min_age = lookup(delete.value, "min_age", null)

      dynamic "delete" {
        for_each = lookup(delete.value, "delete", null) != null ? [lookup(delete.value, "delete", {})] : []
        content {
          delete_searchable_snapshot = lookup(delete.value, "delete_searchable_snapshot", null)
        }
      }

      dynamic "wait_for_snapshot" {
        for_each = lookup(delete.value, "wait_for_snapshot", null) != null ? [lookup(delete.value, "wait_for_snapshot", {})] : []
        content {
          policy = lookup(wait_for_snapshot.value, "policy", null)
        }
      }
    }
  }
}

resource "elasticstack_elasticsearch_index_template" "managed" {
  for_each = local.managed_index_templates_map

  name           = lookup(each.value, "name", null)
  index_patterns = lookup(each.value, "index_patterns", [])
  priority       = lookup(each.value, "priority", null)

  template {
    settings = try(jsonencode(each.value.template.settings), null)
    mappings = try(jsonencode(each.value.template.mappings), null)

    dynamic "alias" {
      for_each = lookup(lookup(each.value, "template", {}), "aliases", [])
      content {
        name = alias.value.name
      }
    }
  }

  dynamic "data_stream" {
    for_each = lookup(each.value, "data_stream", false) ? [1] : []
    content {}
  }

  version     = lookup(each.value, "version", null)
  composed_of = lookup(each.value, "composed_of", null)
}

resource "elasticstack_elasticsearch_index_template_ilm_attachment" "this" {
  for_each = local.index_template_ilm_attachments_map

  index_template = (
    contains(keys(elasticstack_elasticsearch_index_template.managed), lookup(each.value, "index_template", ""))
    ? elasticstack_elasticsearch_index_template.managed[lookup(each.value, "index_template", "")].name
    : lookup(each.value, "index_template", null)
  )
  lifecycle_name = (
    contains(keys(elasticstack_elasticsearch_index_lifecycle.managed), lookup(each.value, "lifecycle_name", ""))
    ? elasticstack_elasticsearch_index_lifecycle.managed[lookup(each.value, "lifecycle_name", "")].name
    : lookup(each.value, "lifecycle_name", null)
  )

  depends_on = [
    elasticstack_elasticsearch_index_lifecycle.managed,
    elasticstack_elasticsearch_index_template.managed
  ]
}

