# resources
module "resources_index" {
  source = "./modules/index/resources/index"
}

module "resources_index_template" {
  source = "./modules/index/resources/index_template"
}

module "resources_api_key" {
  source = "./modules/security/resources/api_key"
}



# data_sources
module "data_sources_index" {
  source = "./modules/index/data_sources/index"
}

module "data_sources_index_template" {
  source = "./modules/index/data_sources/index_template"
}


# special scenarios for resources
## case1: prevent deletion of non-empty indices
module "use_cases_non_empty_index_no_delete" {
  source = "./modules/use_cases/non_empty_index_no_delete"
  es_url      = var.es_url
  es_user     = var.es_user
  es_password = var.es_password
}

## case2: call external http endpoint and use the response
module "use_cases_call_external_http"{
  source = "./modules/use_cases/call_external_http"
}

module "use_cases_call_local_command"{
  source = "./modules/use_cases/call_local_command"
}

module "use_cases_call_local_python"{
  source = "./modules/use_cases/call_local_python"
}