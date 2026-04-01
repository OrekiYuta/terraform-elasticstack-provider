terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.14.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

locals {
  config = yamldecode(file("${path.root}/../gitops/security/resources/api_key.yaml"))

  api_keys = lookup(local.config, "api_keys", [])

  api_keys_map = {
    for k in local.api_keys :
    k.name => k
  }

  # 准备写入文件的 JSON 内容
  api_keys_json = jsonencode({
    for k, r in elasticstack_elasticsearch_security_api_key.this :
    k => r.api_key
  })
}

resource "elasticstack_elasticsearch_security_api_key" "this" {
  for_each = local.api_keys_map

  name = each.value.name
  type = lookup(each.value, "type", null)
  expiration = lookup(each.value, "expiration", null)
  role_descriptors = try(jsonencode(each.value.role_descriptors), null)
  access = lookup(each.value, "access", null)
  metadata = try(jsonencode(each.value.metadata), null)
}


resource "local_file" "api_keys_file" {
  filename = "${path.root}/api_keys.json"
  content  = local.api_keys_json
}

