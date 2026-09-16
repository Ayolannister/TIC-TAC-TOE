terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatecloud"
    container_name       = "terraform-state"
    key                  = "AKS/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------

resource "azurerm_resource_group" "example" {
  name     = "aks-cloud-rg"
  location = "East US"
}

# ---------------------------------------------------------
# AKS Cluster
# ---------------------------------------------------------

resource "azurerm_kubernetes_cluster" "example" {
  name                = "AKS_CLOUD"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "aks-cloud"

  kubernetes_version = "1.35"

  default_node_pool {
    name = "system"

    node_count = 1

    vm_size = "Standard_D2s_v5"


    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "cloud"
    ManagedBy   = "Terraform"
  }
}
