output "aks_config" {
  value = azurerm_kubernetes_cluster.aks
}

output "aks_browse_command" {
  value = "az aks browse --resource-group ${azurerm_kubernetes_cluster.aks.resource_group_name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.aks.kube_config_raw
# }
