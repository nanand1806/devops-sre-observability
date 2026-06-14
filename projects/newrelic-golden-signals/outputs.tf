output "policy_id" {
  description = "ID of the alert policy"
  value       = newrelic_alert_policy.golden.id
}

output "condition_ids" {
  description = "Map of golden signal name to NRQL condition ID"
  value       = { for k, c in newrelic_nrql_alert_condition.golden : k => c.id }
}

output "workflow_id" {
  description = "ID of the notification workflow"
  value       = newrelic_workflow.golden.id
}
