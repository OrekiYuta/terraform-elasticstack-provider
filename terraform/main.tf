# resources
module "index" {
  source = "./modules/index/resources/index"
}

module "index_template" {
  source = "./modules/index/resources/index_template"
}

module "api_key" {
  source = "./modules/security/resources/api_key"
}



# data_sources
module "index_data" {
  source = "./modules/index/data_sources/index"
}



# special scenarios for resources
## case1: prevent deletion of non-empty indices
module "non_empty_index_no_delete" {
  source = "./modules/special_scenarios_tests/non_empty_index_no_delete"
  es_url      = var.es_url
  es_user     = var.es_user
  es_password = var.es_password
}

## case2: call external http endpoint and use the response
module "call_external_http"{
  source = "./modules/special_scenarios_tests/call_external_http"
}

module "call_local_command"{
  source = "./modules/special_scenarios_tests/call_local_command"
}

module "call_local_python"{
  source = "./modules/special_scenarios_tests/call_local_python"
}