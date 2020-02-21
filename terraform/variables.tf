# Vars
variable "azure_resourcegroup_name" {
  default = "__AKS_RG_NAME__"
}

variable "location" {
  default = "uksouth"
}

variable "admin_username" {
  description = "The admin username of the VM(s) that will be deployed"
  default     = "sysadmin"
}

variable "public_ssh_key_path" {
  description = "Public key path for ssh access to the VM"
  default     = "~/.ssh/id_rsa.pub"
}


# ACR
variable "container_registry_name" {
  default = "__ACR_NAME__"
}

variable "acr_admin_enabled" {
  default = false
}

variable "acr_sku" {
  default = "Basic"
}


# AKS
variable "aks_dns_prefix" {
  default = "stvagent1"
}

variable "azurerm_kubernetes_cluster_name" {
  default = "__AKS_CLUSTER_NAME__"
}

variable "enable_aks_dashboard" {
  description = "Should Kubernetes dashboard be enabled"
  default     = true
}

# Service Principle for AKS
variable "service_principal_client_id" {
  default = "__ARM_CLIENT_ID__"
}

variable "service_principal_client_secret" {
  default = "__ARM_CLIENT_SECRET__"
}

# Agent Pool
variable "agent_pool_node_count" {
  default = 1
}

variable "agent_pool_enable_auto_scaling" {
  default = true
}

variable "agent_pool_node_min_count" {
  default = 1
}

variable "agent_pool_node_max_count" {
  default = 3
}

variable "agent_pool_profile_name" {
  default = "default"
}

variable "agent_pool_profile_vm_size" {
  default = "Standard_D1_v2"
}

variable "agent_pool_profile_os_type" {
  default = "Linux"
}

variable "agent_pool_profile_disk_size_gb" {
  default = 30
}


# Misc
variable "tags" {
  description = "A map of the tags to use on the resources"

  default = {
    Environment = "Dev"
    Owner       = "Adam Rush"
    Source      = "terraform"
  }
}
