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
# case1: prevent deletion of non-empty indices
module "non_empty_index_no_delete" {
  source = "./modules/special_scenarios_tests/non_empty_index_no_delete"
}