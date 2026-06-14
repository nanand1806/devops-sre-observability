# Azure Policy is how a landing zone enforces rules automatically. This
# assigns the built-in "Allowed locations" policy at the subscription
# scope, so nobody can create resources outside the approved regions.
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  display_name         = "Allowed locations (landing zone baseline)"
  description          = "Restricts the regions where resources can be created."

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}
