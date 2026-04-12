terraform {
  required_providers {
	elasticstack = {
	  source  = "elastic/elasticstack"
	  version = "0.14.3"
	}
  }
}

locals {
  raw_config = file("${path.root}/../gitops/index/resources/index_lifecycle.yaml")
  config     = try(yamldecode(local.raw_config), {})

  index_lifecycles = try(local.config["index_lifecycles"], [])
  index_lifecycles_map = {
	for item in local.index_lifecycles :
	lookup(item, "name", "") => item
	if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_index_lifecycle" "this" {
  for_each = local.index_lifecycles_map

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

  dynamic "warm" {
	for_each = lookup(each.value, "warm", null) != null ? [lookup(each.value, "warm", {})] : []
	content {
	  min_age = lookup(warm.value, "min_age", null)

	  dynamic "allocate" {
		for_each = lookup(warm.value, "allocate", null) != null ? [lookup(warm.value, "allocate", {})] : []
		content {
		  exclude               = lookup(allocate.value, "exclude", null)
		  include               = lookup(allocate.value, "include", null)
		  number_of_replicas    = lookup(allocate.value, "number_of_replicas", null)
		  require               = lookup(allocate.value, "require", null)
		  total_shards_per_node = lookup(allocate.value, "total_shards_per_node", null)
		}
	  }

	  dynamic "downsample" {
		for_each = lookup(warm.value, "downsample", null) != null ? [lookup(warm.value, "downsample", {})] : []
		content {
		  fixed_interval = lookup(downsample.value, "fixed_interval", null)
		  wait_timeout   = lookup(downsample.value, "wait_timeout", null)
		}
	  }

	  dynamic "forcemerge" {
		for_each = lookup(warm.value, "forcemerge", null) != null ? [lookup(warm.value, "forcemerge", {})] : []
		content {
		  index_codec      = lookup(forcemerge.value, "index_codec", null)
		  max_num_segments = lookup(forcemerge.value, "max_num_segments", null)
		}
	  }

	  dynamic "migrate" {
		for_each = lookup(warm.value, "migrate", null) != null ? [lookup(warm.value, "migrate", {})] : []
		content {
		  enabled = lookup(migrate.value, "enabled", null)
		}
	  }

	  dynamic "readonly" {
		for_each = lookup(warm.value, "readonly", null) != null ? [lookup(warm.value, "readonly", {})] : []
		content {
		  enabled = lookup(readonly.value, "enabled", null)
		}
	  }

	  dynamic "set_priority" {
		for_each = lookup(warm.value, "set_priority", null) != null ? [lookup(warm.value, "set_priority", {})] : []
		content {
		  priority = lookup(set_priority.value, "priority", null)
		}
	  }

	  dynamic "shrink" {
		for_each = lookup(warm.value, "shrink", null) != null ? [lookup(warm.value, "shrink", {})] : []
		content {
		  allow_write_after_shrink = lookup(shrink.value, "allow_write_after_shrink", null)
		  max_primary_shard_size   = lookup(shrink.value, "max_primary_shard_size", null)
		  number_of_shards         = lookup(shrink.value, "number_of_shards", null)
		}
	  }

	  dynamic "unfollow" {
		for_each = lookup(warm.value, "unfollow", null) != null ? [lookup(warm.value, "unfollow", {})] : []
		content {
		  enabled = lookup(unfollow.value, "enabled", null)
		}
	  }
	}
  }

  dynamic "cold" {
	for_each = lookup(each.value, "cold", null) != null ? [lookup(each.value, "cold", {})] : []
	content {
	  min_age = lookup(cold.value, "min_age", null)

	  dynamic "allocate" {
		for_each = lookup(cold.value, "allocate", null) != null ? [lookup(cold.value, "allocate", {})] : []
		content {
		  exclude               = lookup(allocate.value, "exclude", null)
		  include               = lookup(allocate.value, "include", null)
		  number_of_replicas    = lookup(allocate.value, "number_of_replicas", null)
		  require               = lookup(allocate.value, "require", null)
		  total_shards_per_node = lookup(allocate.value, "total_shards_per_node", null)
		}
	  }

	  dynamic "downsample" {
		for_each = lookup(cold.value, "downsample", null) != null ? [lookup(cold.value, "downsample", {})] : []
		content {
		  fixed_interval = lookup(downsample.value, "fixed_interval", null)
		  wait_timeout   = lookup(downsample.value, "wait_timeout", null)
		}
	  }

	  dynamic "freeze" {
		for_each = lookup(cold.value, "freeze", null) != null ? [lookup(cold.value, "freeze", {})] : []
		content {
		  enabled = lookup(freeze.value, "enabled", null)
		}
	  }

	  dynamic "migrate" {
		for_each = lookup(cold.value, "migrate", null) != null ? [lookup(cold.value, "migrate", {})] : []
		content {
		  enabled = lookup(migrate.value, "enabled", null)
		}
	  }

	  dynamic "readonly" {
		for_each = lookup(cold.value, "readonly", null) != null ? [lookup(cold.value, "readonly", {})] : []
		content {
		  enabled = lookup(readonly.value, "enabled", null)
		}
	  }

	  dynamic "searchable_snapshot" {
		for_each = lookup(cold.value, "searchable_snapshot", null) != null ? [lookup(cold.value, "searchable_snapshot", {})] : []
		content {
		  force_merge_index  = lookup(searchable_snapshot.value, "force_merge_index", null)
		  snapshot_repository = lookup(searchable_snapshot.value, "snapshot_repository", null)
		}
	  }

	  dynamic "set_priority" {
		for_each = lookup(cold.value, "set_priority", null) != null ? [lookup(cold.value, "set_priority", {})] : []
		content {
		  priority = lookup(set_priority.value, "priority", null)
		}
	  }

	  dynamic "unfollow" {
		for_each = lookup(cold.value, "unfollow", null) != null ? [lookup(cold.value, "unfollow", {})] : []
		content {
		  enabled = lookup(unfollow.value, "enabled", null)
		}
	  }
	}
  }

  dynamic "frozen" {
	for_each = lookup(each.value, "frozen", null) != null ? [lookup(each.value, "frozen", {})] : []
	content {
	  min_age = lookup(frozen.value, "min_age", null)

	  dynamic "searchable_snapshot" {
		for_each = lookup(frozen.value, "searchable_snapshot", null) != null ? [lookup(frozen.value, "searchable_snapshot", {})] : []
		content {
		  force_merge_index  = lookup(searchable_snapshot.value, "force_merge_index", null)
		  snapshot_repository = lookup(searchable_snapshot.value, "snapshot_repository", null)
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

