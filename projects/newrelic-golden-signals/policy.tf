# One policy groups all golden-signal conditions for this service.
# PER_CONDITION_AND_TARGET opens a separate issue per condition per
# entity, so a latency problem and an error problem are tracked apart.
resource "newrelic_alert_policy" "golden" {
  name                = var.policy_name
  incident_preference = "PER_CONDITION_AND_TARGET"
}
