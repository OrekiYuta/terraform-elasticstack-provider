
```shell

cd terraform
terraform init
terraform plan -target=module.index
terraform apply -target=module.index

```

```windows powershell

terraform plan "-target=module.index"
terraform apply "-target=module.index"

terraform plan -target "module.index"
terraform apply -target="module.index" -auto-approve

terraform plan -target "module.index_data"
terraform apply -target "module.index_data"

terraform plan -target "module.api_key"
terraform apply -target "module.api_key" -auto-approve
terraform destroy -target "module.api_key" -auto-approve


terraform plan -target "module.get_http_resp"

```


```tree
terraform-elasticstack-provider/
├── gitops/
│   └── index/
│       └── resources/
│           ├── index.yaml
│           └── index_template.yaml
│
├── terraform/
│   ├── .terraform/                
│   ├── modules/
│   │   └── index/
│   │       └── resources/
│   │           ├── index/
│   │           │   └── main.tf    
│   │           └── index_template/
│   │               └── main.tf    
│   │
│   ├── main.tf                   # Root module entry point
│   ├── providers.tf              # Provider configuration
│   ├── variables.tf              # Input variable definitions
│   ├── terraform.tfvars          # Variable values
│   └── outputs.tf                # Output definitions
```