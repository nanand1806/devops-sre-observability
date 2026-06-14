# Hub VNet: central network in the platform RG. In a real landing zone
# this holds shared services like a firewall, VPN/ExpressRoute gateway,
# and DNS resolvers.
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${local.name}-hub"
  resource_group_name = azurerm_resource_group.platform.name
  location            = var.location
  address_space       = var.hub_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "hub_shared" {
  name                 = "snet-shared"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_address_space[0], 8, 1)]
}

# Spoke VNet: where workloads run. Peered to the hub so it can use the
# shared services without exposing each workload to the internet.
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${local.name}-spoke"
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location
  address_space       = var.spoke_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(var.spoke_address_space[0], 8, 1)]
}

# NSG with a default deny-all-inbound. Real rules are added per workload;
# starting closed is the safe default for a landing zone.
resource "azurerm_network_security_group" "app" {
  name                = "nsg-${local.name}-app"
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.spoke_app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# Bidirectional peering. Both sides must exist for traffic to flow.
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.workload.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}
