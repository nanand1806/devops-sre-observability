# Golden signals and alerting on New Relic, explained

Companion notes for the [`newrelic-golden-signals`](../projects/newrelic-golden-signals) project. Read this if alerting is new to you or you have only ever clicked alerts together in a UI.

## Start with the question: what do you alert on?

The trap most teams fall into is alerting on everything: every metric, every host, every spike. The result is alert fatigue, where so many alerts fire that people stop reading them, and the one that mattered gets missed.

The fix is to alert on a small set of signals that actually indicate user-facing problems. Google's SRE book offers the canonical set: the **four golden signals**.

## The four golden signals

- **Latency**: how long it takes to serve a request. Alert on a high percentile (p95 or p99), not the average, because the average hides the slow tail that users feel. This project alerts when p95 response time goes above a threshold.
- **Traffic**: how much demand the system is under, usually throughput (requests per minute). A sudden *drop* in traffic is often the first sign of an outage upstream of you, so this project alerts when throughput falls below a floor.
- **Errors**: the rate of requests that fail. Alert on the error percentage, so it scales with traffic instead of needing constant retuning.
- **Saturation**: how full your most constrained resource is, often CPU or memory. Saturation predicts the other three getting worse, so it is your early warning. This project alerts on host CPU.

If you only have time to set up four alerts, these are the four.

## How New Relic alerting fits together

New Relic's model has a few moving parts. Once you see how they connect, the Terraform reads easily:

- **Condition**: the rule. "p95 latency above 1.5s for 5 minutes." Written as a NRQL query plus a threshold. This project has four, one per golden signal.
- **Policy**: a group of conditions. Conditions live inside a policy; the policy is what notifications attach to.
- **Issue**: when a condition breaches, New Relic opens an issue on the policy. Issues are the modern unit New Relic notifies on (it groups related incidents).
- **Destination**: where a notification goes (a Slack webhook, a Teams webhook, PagerDuty, email).
- **Channel**: the formatted message for a destination. Same destination can have different channels with different message layouts.
- **Workflow**: the wiring. "Issues from this policy go to these channels." Filters decide which issues; destinations decide where.

The flow: **condition breaches -> issue on policy -> workflow matches it -> channel formats it -> destination delivers it.**

## NRQL in one minute

New Relic Query Language looks like SQL. A condition's query returns a number New Relic evaluates against your threshold:

```sql
SELECT percentile(duration, 95) FROM Transaction WHERE appName = 'my-service'
```

This says: from transaction events for `my-service`, compute the 95th-percentile duration. New Relic runs this continuously over rolling time windows and compares the result to the threshold.

## Static vs baseline thresholds

- **Static**: a fixed number. "Above 1.5 seconds." Simple and predictable, used throughout this project.
- **Baseline**: New Relic learns the normal pattern and alerts on deviation from it. Good for signals with daily or weekly rhythms (traffic, latency) where a fixed line is either too noisy at peak or too quiet at night.

Start static, move specific signals to baseline once you understand their shape.

## Why message formatting matters

An alert that just says "issue opened" makes the on-call person go digging. A good alert message carries the title, the priority, the current state, and a direct link to the issue. This project's Slack and Teams payloads include exactly those, using New Relic's template variables. Add a runbook link and you turn a page at 3am into "click here, follow these steps."

## Why do this in Terraform at all?

Clicking alerts together in a UI works until you have dozens of services. Then you have no record of who changed what, no review before a threshold goes live, no way to copy a known-good setup to a new service, and no way to recover if someone deletes a policy. As code, your alerting is reviewed in pull requests, versioned, and reproducible. The same reasons you keep infrastructure in Terraform apply to the alerts watching it.
