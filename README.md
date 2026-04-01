
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

```


```tree
terraform-elasticstack-provider
    - gitops/
        index/
          resources/
            - index.yaml
            - index_template.yaml
    - terraform/
        - modules/
           index/
              resources/
                index/
                  main.tf
        - main.tf
        - providers.tf
        - terraform.tfvars
        - variables.tf

```