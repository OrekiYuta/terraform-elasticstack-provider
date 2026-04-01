module "index" {
  source = "./modules/index/resources/index"
}

module "index_template" {
  source = "./modules/index/resources/index_template"
}

module "api_key" {
  source = "./modules/security/resources/api_key"
}

module "index_data" {
  source = "./modules/index/data_sources/index"
}

