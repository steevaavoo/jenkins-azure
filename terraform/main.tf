# Configure Providers
provider "azurerm" {
  # Pin version as per best practice
  version = "=1.41.0"
}


# Vars
locals {
  aks_cluster_name             = "${random_string.random.result}-aks"
  log_analytics_workspace_name = "${var.azurerm_kubernetes_cluster_name}-workspace"
}


resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
  number  = false
}


# Deploying Terraform Remote State to AZ Storage Container
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    storage_account_name = "__TERRAFORM_STORAGE_ACCOUNT__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    access_key           = "__STORAGE_KEY__"
  }
}

resource "azurerm_resource_group" "aks" {
  name     = var.azure_resourcegroup_name
  location = var.location
}

resource "azurerm_container_registry" "aks" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = var.acr_sku
}


# Log Analytics
resource "azurerm_log_analytics_workspace" "aks" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant
  name                = local.log_analytics_workspace_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "aks" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.aks.location
  resource_group_name   = azurerm_resource_group.aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  workspace_name        = azurerm_log_analytics_workspace.aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.azurerm_kubernetes_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name                = var.agent_pool_profile_name
    type                = "VirtualMachineScaleSets"
    node_count          = var.agent_pool_node_count
    vm_size             = var.agent_pool_profile_vm_size
    os_disk_size_gb     = var.agent_pool_profile_disk_size_gb
    enable_auto_scaling = var.agent_pool_enable_auto_scaling
    min_count           = var.agent_pool_node_min_count
    max_count           = var.agent_pool_node_max_count
  }

  # linux_profile {
  #   admin_username = var.admin_username

  #   ssh_key {
  #     key_data = file(var.public_ssh_key_path)
  #   }
  # }

  service_principal {
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }

  addon_profile {
    kube_dashboard {
      enabled = var.enable_aks_dashboard
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      service_principal,
      default_node_pool[0].node_count,
      # addon_profile,
    ]
  }
}

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.aks.kube_config_raw
# }
