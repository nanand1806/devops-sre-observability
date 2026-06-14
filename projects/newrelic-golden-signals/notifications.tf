# Destinations are "where" notifications go. Channels are "what" the
# message looks like for a given destination. A workflow connects a
# policy's issues to one or more channels.

# --- Slack ---
resource "newrelic_notification_destination" "slack" {
  account_id = var.account_id
  name       = "Slack - golden signals"
  type       = "WEBHOOK"

  property {
    key   = "url"
    value = var.slack_webhook_url
  }
}

resource "newrelic_notification_channel" "slack" {
  account_id     = var.account_id
  name           = "Slack channel - golden signals"
  type           = "WEBHOOK"
  destination_id = newrelic_notification_destination.slack.id
  product        = "IINT"

  property {
    key = "payload"
    value = jsonencode({
      text = ":rotating_light: *{{ issueTitle }}*\nPriority: {{ priority }} | State: {{ state }}\n<{{ issuePageUrl }}|Open issue in New Relic>"
    })
    label = "Payload Template"
  }
}

# --- Microsoft Teams (via incoming webhook + MessageCard) ---
resource "newrelic_notification_destination" "teams" {
  account_id = var.account_id
  name       = "Teams - golden signals"
  type       = "WEBHOOK"

  property {
    key   = "url"
    value = var.teams_webhook_url
  }
}

resource "newrelic_notification_channel" "teams" {
  account_id     = var.account_id
  name           = "Teams channel - golden signals"
  type           = "WEBHOOK"
  destination_id = newrelic_notification_destination.teams.id
  product        = "IINT"

  property {
    key = "payload"
    value = jsonencode({
      "@type"    = "MessageCard"
      "@context" = "http://schema.org/extensions"
      themeColor = "D63333"
      summary    = "{{ issueTitle }}"
      sections = [{
        activityTitle = "{{ issueTitle }}"
        facts = [
          { name = "Priority", value = "{{ priority }}" },
          { name = "State", value = "{{ state }}" },
        ]
      }]
      potentialAction = [{
        "@type" = "OpenUri"
        name    = "Open in New Relic"
        targets = [{ os = "default", uri = "{{ issuePageUrl }}" }]
      }]
    })
    label = "Payload Template"
  }
}

# The workflow ties the policy's issues to both channels. Every issue
# raised by a golden-signal condition is delivered to Slack and Teams.
resource "newrelic_workflow" "golden" {
  account_id            = var.account_id
  name                  = "Golden signals to Slack and Teams"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "golden-signals-policy"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.golden.id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.slack.id
  }

  destination {
    channel_id = newrelic_notification_channel.teams.id
  }
}
