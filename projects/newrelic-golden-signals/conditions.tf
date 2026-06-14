# The four golden signals (Google SRE): latency, traffic, errors,
# saturation. Each is one NRQL condition. They are defined in a map and
# created with for_each so the alerting logic stays DRY and consistent.
locals {
  golden_signals = {
    latency = {
      name      = "Golden Signal - Latency (p95)"
      query     = "SELECT percentile(duration, 95) FROM Transaction WHERE appName = '${var.app_name}'"
      operator  = "above"
      threshold = var.latency_threshold_seconds
    }
    errors = {
      name      = "Golden Signal - Error rate"
      query     = "SELECT percentage(count(*), WHERE error IS true) FROM Transaction WHERE appName = '${var.app_name}'"
      operator  = "above"
      threshold = var.error_rate_threshold_percent
    }
    traffic = {
      name      = "Golden Signal - Traffic (throughput drop)"
      query     = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = '${var.app_name}'"
      operator  = "below"
      threshold = var.min_throughput_rpm
    }
    saturation = {
      name      = "Golden Signal - Saturation (host CPU)"
      query     = "SELECT average(cpuPercent) FROM SystemSample"
      operator  = "above"
      threshold = var.cpu_saturation_threshold_percent
    }
  }
}

resource "newrelic_nrql_alert_condition" "golden" {
  for_each = local.golden_signals

  policy_id   = newrelic_alert_policy.golden.id
  type        = "static"
  name        = each.value.name
  description = "Golden signal alert. Runbook: ${var.runbook_url}"
  enabled     = true

  # Streaming aggregation settings. event_flow waits aggregation_delay
  # seconds for late data before evaluating each 60s window.
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 120

  nrql {
    query = each.value.query
  }

  critical {
    operator              = each.value.operator
    threshold             = each.value.threshold
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}
