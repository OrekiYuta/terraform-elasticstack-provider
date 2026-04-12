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
  config     = length(trimspace(local.raw_config)) > 0 ? yamldecode(local.raw_config) : {}

  index_template_ilm_attachments = try(local.config["index_template_ilm_attachments"], [])
  index_template_ilm_attachments_map = {
	for item in local.index_template_ilm_attachments :
	"${lookup(item, "index_template", "")}::${lookup(item, "lifecycle_name", "")}" => item
	if lookup(item, "index_template", "") != "" && lookup(item, "lifecycle_name", "") != ""
  }
}

resource "elasticstack_elasticsearch_index_template_ilm_attachment" "this" {
  for_each = local.index_template_ilm_attachments_map

  index_template = lookup(each.value, "index_template", null)
  lifecycle_name = lookup(each.value, "lifecycle_name", null)
}

