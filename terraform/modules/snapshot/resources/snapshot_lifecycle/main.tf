terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
  }
}

locals {
  raw_config = file("${path.root}/../gitops/snapshot/resources/snapshot_lifecycle.yaml")
  config     = try(yamldecode(local.raw_config), {})
  snapshot_repositories = try(local.config["snapshot_repositories"], [])
  snapshot_repositories_map = {
    for item in local.snapshot_repositories :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }

  snapshot_lifecycle_policies = try(local.config["snapshot_lifecycle_policies"], [])
  snapshot_lifecycle_policies_map = {
    for item in local.snapshot_lifecycle_policies :
    lookup(item, "name", "") => item
    if lookup(item, "name", "") != ""
  }
}

resource "elasticstack_elasticsearch_snapshot_repository" "managed" {
  for_each = local.snapshot_repositories_map

  name   = lookup(each.value, "name", null)
  verify = lookup(each.value, "verify", null)

  dynamic "fs" {
    for_each = contains(keys(each.value), "fs") ? [lookup(each.value, "fs", {})] : (lookup(each.value, "type", "") == "fs" ? [lookup(each.value, "settings", {})] : [])
    content {
      location                   = lookup(fs.value, "location", null)
      compress                   = lookup(fs.value, "compress", null)
      chunk_size                 = lookup(fs.value, "chunk_size", null)
      max_number_of_snapshots    = lookup(fs.value, "max_number_of_snapshots", null)
      max_restore_bytes_per_sec  = lookup(fs.value, "max_restore_bytes_per_sec", null)
      max_snapshot_bytes_per_sec = lookup(fs.value, "max_snapshot_bytes_per_sec", null)
      readonly                   = lookup(fs.value, "readonly", null)
    }
  }

  dynamic "s3" {
    for_each = contains(keys(each.value), "s3") ? [lookup(each.value, "s3", {})] : (lookup(each.value, "type", "") == "s3" ? [lookup(each.value, "settings", {})] : [])
    content {
      bucket                     = lookup(s3.value, "bucket", null)
      base_path                  = lookup(s3.value, "base_path", null)
      client                     = lookup(s3.value, "client", null)
      compress                   = lookup(s3.value, "compress", null)
      endpoint                   = lookup(s3.value, "endpoint", null)
      readonly                   = lookup(s3.value, "readonly", null)
      server_side_encryption     = lookup(s3.value, "server_side_encryption", null)
      storage_class              = lookup(s3.value, "storage_class", null)
      path_style_access          = lookup(s3.value, "path_style_access", null)
      buffer_size                = lookup(s3.value, "buffer_size", null)
      chunk_size                 = lookup(s3.value, "chunk_size", null)
      canned_acl                 = lookup(s3.value, "canned_acl", null)
      max_restore_bytes_per_sec  = lookup(s3.value, "max_restore_bytes_per_sec", null)
      max_snapshot_bytes_per_sec = lookup(s3.value, "max_snapshot_bytes_per_sec", null)
    }
  }

  dynamic "gcs" {
    for_each = contains(keys(each.value), "gcs") ? [lookup(each.value, "gcs", {})] : (lookup(each.value, "type", "") == "gcs" ? [lookup(each.value, "settings", {})] : [])
    content {
      bucket                     = lookup(gcs.value, "bucket", null)
      base_path                  = lookup(gcs.value, "base_path", null)
      client                     = lookup(gcs.value, "client", null)
      compress                   = lookup(gcs.value, "compress", null)
      chunk_size                 = lookup(gcs.value, "chunk_size", null)
      readonly                   = lookup(gcs.value, "readonly", null)
      max_restore_bytes_per_sec  = lookup(gcs.value, "max_restore_bytes_per_sec", null)
      max_snapshot_bytes_per_sec = lookup(gcs.value, "max_snapshot_bytes_per_sec", null)
    }
  }

  dynamic "azure" {
    for_each = contains(keys(each.value), "azure") ? [lookup(each.value, "azure", {})] : (lookup(each.value, "type", "") == "azure" ? [lookup(each.value, "settings", {})] : [])
    content {
      container                  = lookup(azure.value, "container", null)
      client                     = lookup(azure.value, "client", null)
      base_path                  = lookup(azure.value, "base_path", null)
      location_mode              = lookup(azure.value, "location_mode", null)
      compress                   = lookup(azure.value, "compress", null)
      chunk_size                 = lookup(azure.value, "chunk_size", null)
      readonly                   = lookup(azure.value, "readonly", null)
      max_restore_bytes_per_sec  = lookup(azure.value, "max_restore_bytes_per_sec", null)
      max_snapshot_bytes_per_sec = lookup(azure.value, "max_snapshot_bytes_per_sec", null)
    }
  }

  dynamic "url" {
    for_each = contains(keys(each.value), "url") ? [lookup(each.value, "url", {})] : (lookup(each.value, "type", "") == "url" ? [lookup(each.value, "settings", {})] : [])
    content {
      url                        = lookup(url.value, "url", null)
      compress                   = lookup(url.value, "compress", null)
      chunk_size                 = lookup(url.value, "chunk_size", null)
      http_max_retries           = lookup(url.value, "http_max_retries", null)
      http_socket_timeout        = lookup(url.value, "http_socket_timeout", null)
      max_number_of_snapshots    = lookup(url.value, "max_number_of_snapshots", null)
      readonly                   = lookup(url.value, "readonly", null)
      max_restore_bytes_per_sec  = lookup(url.value, "max_restore_bytes_per_sec", null)
      max_snapshot_bytes_per_sec = lookup(url.value, "max_snapshot_bytes_per_sec", null)
    }
  }

  dynamic "hdfs" {
    for_each = contains(keys(each.value), "hdfs") ? [lookup(each.value, "hdfs", {})] : (lookup(each.value, "type", "") == "hdfs" ? [lookup(each.value, "settings", {})] : [])
    content {
      uri                        = lookup(hdfs.value, "uri", null)
      path                       = lookup(hdfs.value, "path", null)
      compress                   = lookup(hdfs.value, "compress", null)
      chunk_size                 = lookup(hdfs.value, "chunk_size", null)
      load_defaults              = lookup(hdfs.value, "load_defaults", null)
      readonly                   = lookup(hdfs.value, "readonly", null)
      max_restore_bytes_per_sec  = lookup(hdfs.value, "max_restore_bytes_per_sec", null)
      max_snapshot_bytes_per_sec = lookup(hdfs.value, "max_snapshot_bytes_per_sec", null)
    }
  }
}

resource "elasticstack_elasticsearch_snapshot_lifecycle" "this" {
  for_each = local.snapshot_lifecycle_policies_map

  name                 = lookup(each.value, "name", null)
  schedule             = lookup(each.value, "schedule", null)
  repository = (
    contains(keys(elasticstack_elasticsearch_snapshot_repository.managed), lookup(each.value, "repository", ""))
    ? elasticstack_elasticsearch_snapshot_repository.managed[lookup(each.value, "repository", "")].name
    : lookup(each.value, "repository", null)
  )
  snapshot_name        = lookup(each.value, "snapshot_name", null)
  indices              = lookup(lookup(each.value, "config", {}), "indices", null)
  include_global_state = lookup(lookup(each.value, "config", {}), "include_global_state", null)
  feature_states       = lookup(lookup(each.value, "config", {}), "feature_states", null)
  ignore_unavailable   = lookup(lookup(each.value, "config", {}), "ignore_unavailable", null)
  partial              = lookup(lookup(each.value, "config", {}), "partial", null)
  expand_wildcards     = lookup(lookup(each.value, "config", {}), "expand_wildcards", null)
  metadata             = lookup(each.value, "metadata", null)

  expire_after = lookup(lookup(each.value, "retention", {}), "expire_after", null)
  min_count    = lookup(lookup(each.value, "retention", {}), "min_count", null)
  max_count    = lookup(lookup(each.value, "retention", {}), "max_count", null)

  depends_on = [elasticstack_elasticsearch_snapshot_repository.managed]
}

