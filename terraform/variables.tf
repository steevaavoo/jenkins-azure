variable "container_registry_name" {
  default = "stvcontReg1"
}

variable "acr_admin_enabled" {
  default = false
}

variable "acr_sku" {
  default = "Basic"
}


variable "aks_dns_prefix" {
  default = "stvagent1"
}

variable "azure_resourcegroup_name" {
  default = "__aksrgname__"
}

variable "location" {
  default = "East US"
}

variable "agent_pool_count" {
  default = 2
}

variable "azurerm_kubernetes_cluster_name" {
  default = "__aksclustername__"
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

variable "service_principal_client_id" {
  default = "__clientid__"
}

variable "service_principal_client_secret" {
  default = "__clientsecret__"
}

