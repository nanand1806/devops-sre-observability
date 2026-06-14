variable "account_id" {
  description = "New Relic account ID"
  type        = number
}

variable "api_key" {
  description = "New Relic User API key (NRAK-...). Set via TF_VAR_api_key, never commit it."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "New Relic region: US or EU"
  type        = string
  default     = "US"

  validation {
    condition     = contains(["US", "EU"], var.region)
    error_message = "region must be US or EU."
  }
}

variable "app_name" {
  description = "APM application name to monitor (appName in NRQL)"
  type        = string
  default     = "my-service"
}

variable "policy_name" {
  description = "Name of the alert policy"
  type        = string
  default     = "Golden Signals - my-service"
}

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL. Set via TF_VAR_slack_webhook_url."
  type        = string
  sensitive   = true
}

variable "teams_webhook_url" {
  description = "Microsoft Teams incoming webhook URL. Set via TF_VAR_teams_webhook_url."
  type        = string
  sensitive   = true
}

variable "latency_threshold_seconds" {
  description = "Critical p95 latency threshold in seconds"
  type        = number
  default     = 1.5
}

variable "error_rate_threshold_percent" {
  description = "Critical error-rate threshold as a percentage"
  type        = number
  default     = 5
}

variable "min_throughput_rpm" {
  description = "Alert if throughput drops below this (requests per minute)"
  type        = number
  default     = 1
}

variable "cpu_saturation_threshold_percent" {
  description = "Critical host CPU saturation threshold as a percentage"
  type        = number
  default     = 85
}

variable "runbook_url" {
  description = "Runbook URL attached to each condition (your wiki/Confluence page)"
  type        = string
  default     = "https://example.com/runbooks/golden-signals"
}
