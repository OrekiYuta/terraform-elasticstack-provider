### Terraform basic Command

```shell
cd terraform
terraform init
terraform plan
terraform apply
```

### Resources - Command

```shell
terraform plan -target "module.resources_enrich_policy"
terraform apply -target="module.resources_enrich_policy" -auto-approve

terraform plan -target "module.resources_index"
terraform apply -target="module.resources_index" -auto-approve

terraform plan -target "module.resources_index_template"
terraform apply -target="module.resources_index_template" -auto-approve

terraform plan -target "module.resources_component_template"
terraform apply -target="module.resources_component_template" -auto-approve

terraform plan -target "module.resources_data_stream"
terraform apply -target="module.resources_data_stream" -auto-approve

terraform plan -target "module.resources_data_stream_lifecycle"
terraform apply -target="module.resources_data_stream_lifecycle" -auto-approve

terraform plan -target "module.resources_index_alias"
terraform apply -target="module.resources_index_alias" -auto-approve

terraform plan -target "module.resources_index_lifecycle"
terraform apply -target="module.resources_index_lifecycle" -auto-approve

terraform plan -target "module.resources_index_template_ilm_attachment"
terraform apply -target="module.resources_index_template_ilm_attachment" -auto-approve

terraform plan -target "module.resources_data_view"
terraform apply -target="module.resources_data_view" -auto-approve

terraform plan -target "module.resources_import_saved_objects"
terraform apply -target="module.resources_import_saved_objects" -auto-approve

terraform plan -target "module.resources_space"
terraform apply -target="module.resources_space" -auto-approve

terraform plan -target "module.resources_logstash_pipeline"
terraform apply -target="module.resources_logstash_pipeline" -auto-approve

terraform plan -target "module.resources_api_key"
terraform apply -target "module.resources_api_key" -auto-approve
terraform destroy -target "module.resources_api_key" -auto-approve

terraform plan -target "module.resources_role"
terraform apply -target="module.resources_role" -auto-approve

terraform plan -target "module.resources_role_mapping"
terraform apply -target="module.resources_role_mapping" -auto-approve

terraform plan -target "module.resources_user"
terraform apply -target="module.resources_user" -auto-approve

terraform plan -target "module.resources_snapshot_lifecycle"
terraform apply -target="module.resources_snapshot_lifecycle" -auto-approve

terraform plan -target "module.resources_snapshot_repository"
terraform apply -target="module.resources_snapshot_repository" -auto-approve
```

### Data Sources - Command

```shell
terraform plan -target "module.data_sources_index"
terraform plan -target "module.data_sources_index_template"
terraform plan -target "module.data_sources_enrich_policy"
terraform plan -target "module.data_sources_space"
terraform plan -target "module.data_sources_export_saved_objects"
terraform plan -target "module.data_sources_role"
terraform plan -target "module.data_sources_role_mapping"
terraform plan -target "module.data_sources_user"
terraform plan -target "module.data_sources_snapshot_repository"
```

### Use Cases - Command

```shell
terraform plan -target "module.use_cases_call_external_http"
terraform plan -target "module.use_cases_call_local_command"
terraform plan -target "module.use_cases_call_local_python"

terraform plan -target "module.use_cases_non_empty_index_no_delete"
terraform apply -target "module.use_cases_non_empty_index_no_delete" -auto-approve
```

### Project Tree

```tree
terraform-elasticstack-provider/
├── .env
├── .git/
├── .gitignore
├── .idea/
├── README.md
├── requirements.txt
├── venv/
├── scripts/
│   ├── index_docs_manager.py
│   └── __pycache__/
├── gitops/
│   ├── index/
│   │   ├── data_sources/
│   │   └── resources/
│   │       ├── index.yaml
│   │       └── index_template.yaml
│   ├── security/
│   │   └── resources/
│   │       └── api_key.yaml
│   └── special_scenarios_tests/
│       └── non_empty_index_no_delete/
│           └── index.yaml
└── terraform/
    ├── .terraform/
    ├── .terraform.lock.hcl
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfstate
    ├── terraform.tfvars
    ├── variables.tf
    └── modules/
        ├── index/
        │   ├── data_sources/
        │   │   ├── index/
        │   │   │   └── main.tf
        │   │   └── index_template/
        │   └── resources/
        │       ├── index/
        │       │   └── main.tf
        │       └── index_template/
        │           └── main.tf
        ├── security/
        │   ├── data_sources/
        │   └── resources/
        │       └── api_key/
        │           ├── api_keys.json
        │           └── main.tf
        └── special_scenarios_tests/
            ├── call_external_http/
            │   └── main.tf
            ├── call_local_command/
            │   └── main.tf
            ├── call_local_python/
            │   ├── call_http.py
            │   └── main.tf
            └── non_empty_index_no_delete/
                ├── custom_validation.py
                └── main.tf
```