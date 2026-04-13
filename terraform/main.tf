# resources
module "resources_enrich_policy" {
  source = "./modules/enrich/resources/enrich_policy"
}

module "resources_index" {
  source = "./modules/index/resources/index"
}

module "resources_index_template" {
  source = "./modules/index/resources/index_template"
}

module "resources_component_template" {
  source = "./modules/index/resources/component_template"
}

module "resources_data_stream" {
  source = "./modules/index/resources/data_stream"
}

module "resources_data_stream_lifecycle" {
  source = "./modules/index/resources/data_stream_lifecycle"
}

module "resources_index_alias" {
  source = "./modules/index/resources/index_alias"
}

module "resources_index_lifecycle" {
  source = "./modules/index/resources/index_lifecycle"
}

module "resources_index_template_ilm_attachment" {
  source = "./modules/index/resources/index_template_ilm_attachment"
}

module "resources_data_view" {
  source = "./modules/kibana/resources/data_view"
}

module "resources_import_saved_objects" {
  source = "./modules/kibana/resources/import_saved_objects"
}

module "resources_space" {
  source = "./modules/kibana/resources/space"
}

module "resources_logstash_pipeline" {
  source = "./modules/logstash/resources/logstash_pipeline"
}

module "resources_api_key" {
  source = "./modules/security/resources/api_key"
}

module "resources_role" {
  source = "./modules/security/resources/role"
}

module "resources_role_mapping" {
  source = "./modules/security/resources/role_mapping"
}

module "resources_user" {
  source = "./modules/security/resources/user"
}

module "resources_snapshot_lifecycle" {
  source = "./modules/snapshot/resources/snapshot_lifecycle"
}

module "resources_snapshot_repository" {
  source = "./modules/snapshot/resources/snapshot_repository"
}

# data_sources
module "data_sources_index" {
  source = "./modules/index/data_sources/index"
}

module "data_sources_index_template" {
  source = "./modules/index/data_sources/index_template"
}

module "data_sources_enrich_policy" {
  source = "./modules/enrich/data_sources/enrich_policy"
}

module "data_sources_space" {
  source = "./modules/kibana/data_sources/space"
}

module "data_sources_export_saved_objects" {
  source = "./modules/kibana/data_sources/export_saved_objects"
}

module "data_sources_role" {
  source = "./modules/security/data_sources/role"
}

module "data_sources_role_mapping" {
  source = "./modules/security/data_sources/role_mapping"
}

module "data_sources_user" {
  source = "./modules/security/data_sources/user"
}

module "data_sources_snapshot_repository" {
  source = "./modules/snapshot/data_sources/snapshot_repository"
}

# special scenarios for resources
module "use_cases_call_external_http" {
  source = "./modules/use_cases/call_external_http"
}

module "use_cases_call_local_command" {
  source = "./modules/use_cases/call_local_command"
}

module "use_cases_call_local_python" {
  source = "./modules/use_cases/call_local_python"
}

module "use_cases_http_non_empty_index_no_delete" {
  source      = "./modules/use_cases/http_non_empty_index_no_delete"
  es_url      = var.es_url
  es_user     = var.es_user
  es_password = var.es_password
}

module "use_cases_python_non_empty_index_no_delete" {
  source      = "./modules/use_cases/python_non_empty_index_no_delete"
  es_url      = var.es_url
  es_user     = var.es_user
  es_password = var.es_password
}
