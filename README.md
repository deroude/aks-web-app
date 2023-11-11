```bash
az login --tenant xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
az account list --output table
az account set --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
az ad sp create-for-rbac --name my_sp_name --role Contributor --scopes /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```


```bash
terraform init --upgrade --backend-config=config.azurerm.tfbackend
terraform plan -var-file=stage.tfvars
```
