locals {
  name = "${var.project_name}-${var.environment}"
}

# Platform resource group: shared, central services (networking hub,
# logging, secrets). Owned by the platform/DevOps team.
resource "azurerm_resource_group" "platform" {
  name     = "rg-${local.name}-platform"
  location = var.location
  tags     = var.tags
}

# Workload resource group: where application teams deploy. Isolated
# from the platform layer so blast radius and access stay separate.
resource "azurerm_resource_group" "workload" {
  name     = "rg-${local.name}-workload"
  location = var.location
  tags     = var.tags
}
