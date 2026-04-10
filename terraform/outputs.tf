output "application_indices_details" {
  value = module.data_sources_index.application_indices_details
}

output "call_external_http" {
  value = module.use_cases_call_external_http
}

output "call_local_command" {
  value = module.use_cases_call_local_command
}

output "call_local_python" {
  value = module.use_cases_call_local_python
}