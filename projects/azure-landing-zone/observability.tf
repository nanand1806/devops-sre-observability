# Central Log Analytics workspace in the platform RG. Every resource in
# the landing zone sends diagnostics here, so logs and metrics live in one
# place the platform team controls.
resource "azurerm_log_analytics_workspace" "central" {
  name                = "log-${local.name}"
  resource_group_name = azurerm_resource_group.platform.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}
