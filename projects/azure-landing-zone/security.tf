data "azurerm_client_config" "current" {}

# Key Vault names are globally unique and capped at 24 characters, so we
# append a short random suffix. RBAC authorization (not access policies)
# is the current recommended model.
resource "random_string" "kv" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_key_vault" "this" {
  name                       = substr("kv${var.project_name}${var.environment}${random_string.kv.result}", 0, 24)
  resource_group_name        = azurerm_resource_group.platform.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  tags                       = var.tags
}
