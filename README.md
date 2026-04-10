
```shell
cd terraform
terraform init

terraform plan "-target=module.resources_index"
terraform apply "-target=module.resources_index"

terraform plan -target "module.resources_index"
terraform apply -target="module.resources_index" -auto-approve

terraform plan -target "module.data_sources_index"
terraform apply -target "module.data_sources_index"

terraform plan -target "module.resources_api_key"
terraform apply -target "module.resources_api_key" -auto-approve
terraform destroy -target "module.resources_api_key" -auto-approve


terraform plan -target "module.use_cases_call_external_http"
terraform plan -target "module.use_cases_call_local_command"
terraform plan -target "module.use_cases_call_local_python"

terraform plan -target "module.use_cases_non_empty_index_no_delete"
terraform apply -target "module.use_cases_non_empty_index_no_delete" -auto-approve

```


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