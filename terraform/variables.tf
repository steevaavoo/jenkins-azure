variable "container_registry_name" {
  default = "__ACR_NAME__"
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
  default = "__AKS_RG_NAME__"
}

variable "location" {
  default = "uksouth"
}

variable "agent_pool_count" {
  default = 2
}

variable "azurerm_kubernetes_cluster_name" {
  default = "__AKS_CLUSTER_NAME__"
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
  default = "__ARM_CLIENT_ID__"
}

variable "service_principal_client_secret" {
  default = "__ARM_CLIENT_SECRET__"
}
