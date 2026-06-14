output "platform_resource_group" {
  description = "Name of the platform (shared services) resource group"
  value       = azurerm_resource_group.platform.name
}

output "workload_resource_group" {
  description = "Name of the workload resource group"
  value       = azurerm_resource_group.workload.name
}

output "hub_vnet_id" {
  description = "Resource ID of the hub VNet"
  value       = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  description = "Resource ID of the spoke VNet"
  value       = azurerm_virtual_network.spoke.id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the central Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.central.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}
