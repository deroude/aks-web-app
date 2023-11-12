// create Azure resource group

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.prefix}-rg"
}

// create Azure storage account

resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}k8sstorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

// create Azure file share

resource "azurerm_storage_share" "share" {
  name                 = "${var.prefix}share"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
}

// create Azure container registry

resource "azurerm_container_registry" "acr" {
  name                     = "${var.prefix}k8sacr"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Standard"
  admin_enabled            = true
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "${var.prefix}-ssh-key"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
}

output "key_data" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
}

resource "azurerm_virtual_network" "apim-aks" {
  name                = "apim-aks-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.apim-aks.name}"
  address_prefix       = "10.10.1.0/24"
}

resource "azurerm_subnet" "apim" {
  name                 = "apim-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.apim-aks.name}"
  address_prefix       = "10.10.2.0/24"
}

// create AKS cluster

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.prefix}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.k8s_node_count
    vnet_subnet_id = "${azurerm_subnet.aks.id}"
  }
  linux_profile {
    admin_username = "whistle"

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

// Create API Management

resource "azurerm_api_management" "apim" {
  name                = "whistle-apim"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  publisher_name      = "Valentin Raduti"
  publisher_email     = "valentin@thedotin.ro"

  sku {
    name     = "Developer"
    capacity = 1
  }

  virtual_network_type = "External"
  virtual_network_configuration {
    subnet_id = "${azurerm_subnet.apim.id}"
  }
}
