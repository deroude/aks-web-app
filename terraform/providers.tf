terraform {
  required_version = ">=1.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_msi              = true
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.credentials.subscription_id
  tenant_id       = var.credentials.tenant_id
  client_id       = var.credentials.app_id
  client_secret   = var.credentials.secret
}
