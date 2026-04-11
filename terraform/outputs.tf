# Data Sources
output "data_sources_enrich_policy" {
  value = module.data_sources_enrich_policy.enrich_policy_info
}

output "data_sources_index_info" {
  value = module.data_sources_index.index_info
}

output "data_sources_index_template_info" {
  value = module.data_sources_index_template.index_template_info
}


output "data_sources_space" {
  value = module.data_sources_space
}

output "data_sources_export_saved_objects" {
  value = module.data_sources_export_saved_objects
}

output "data_sources_role" {
  value = module.data_sources_role
}

output "data_sources_role_mapping" {
  value = module.data_sources_role_mapping
}

output "data_sources_user" {
  value = module.data_sources_user
}

output "data_sources_snapshot_repository" {
  value = module.data_sources_snapshot_repository
}

# Use cases
output "use_case_call_external_http" {
  value = module.use_cases_call_external_http
}

output "use_case_call_local_command" {
  value = module.use_cases_call_local_command
}

output "use_case_call_local_python" {
  value = module.use_cases_call_local_python
}

output "use_cases_non_empty_index_no_delete" {
  value = module.use_cases_non_empty_index_no_delete
}
