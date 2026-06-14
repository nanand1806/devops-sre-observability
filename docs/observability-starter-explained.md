# SLOs, error budgets, and burn-rate alerting, explained

Companion notes for the [`observability-starter`](../projects/observability-starter) project. Read this if SLO, SLI, and "burn rate" are words you have nodded along to without being sure of.

## Start with the three letters: SLI, SLO, SLA

- **SLI (indicator)**: a number that measures how good the service is right now. For example, the percentage of requests that succeed. It is a measurement.
- **SLO (objective)**: the target for that number, for example "99.9% of requests succeed over 30 days." It is a goal you set.
- **SLA (agreement)**: a contract with consequences if you miss the SLO. It is a business promise, usually looser than your internal SLO.

You operate against the SLO. The SLA is for lawyers.

## The error budget

If your SLO is 99.9% success, then 0.1% failure is allowed. That 0.1% is your **error budget**. It reframes reliability from "never fail" (impossible) to "fail no more than this much," which is both achievable and measurable.

The error budget is useful because it turns reliability into a quantity you can spend. Shipping fast and occasionally breaking things is fine as long as you stay within budget. Burn the budget too fast and the signal is "slow down, stabilize." It replaces arguments with arithmetic.

## What "burn rate" means

Burn rate is how fast you are consuming the error budget relative to the allowed pace.

- Burn rate 1: you are spending the budget exactly as fast as allowed. At this rate it lasts the full 30-day window.
- Burn rate 14.4: you are spending 14.4 times too fast. At this rate you would burn 2% of the monthly budget in a single hour.

Alerting on burn rate, rather than on a raw error percentage, means your alerts are tied directly to the thing you actually care about: are we about to run out of budget?

## Why two windows per alert

A naive alert says "error rate above 1% for 5 minutes." It has two problems: it fires on tiny harmless blips, and once the blip passes it can keep firing on a long averaging window.

Multi-window, multi-burn-rate alerting fixes both by requiring two conditions at once:

- A **long window** (say 1 hour): confirms the problem is real and sustained, not a momentary spike.
- A **short window** (say 5 minutes): confirms it is still happening right now, so the alert clears quickly once you fix it.

Both must be breached for the alert to fire. That combination is what makes these alerts both sensitive to real outages and quiet the rest of the time.

## The tiers in this project

The project defines four alerts at decreasing severity:

| Burn rate | Windows | Why this pairing | Action |
|---|---|---|---|
| 14.4x | 1h / 5m | A severe, fast outage. Budget gone in days. | Page someone now |
| 6x | 6h / 30m | A serious sustained problem. | Page someone |
| 3x | 1d / 2h | A slow leak worth attention this week. | Open a ticket |
| 1x | 3d / 6h | A steady drift before it becomes urgent. | Open a ticket |

The fast burns page a human; the slow burns open tickets. Same SLO, severity matched to urgency.

## Recording rules

A recording rule precomputes a query and stores the result as a new metric on every evaluation. This project records the error ratio over each window (`job:slo_errors:ratio_rate5m`, `...rate1h`, and so on). Two reasons: the alert expressions stay readable, and dashboards that reuse the value do not recompute an expensive query every refresh.

## The four golden signals on the dashboard

The dashboard shows the same four signals from the New Relic project, here measured in Prometheus:

- **Latency**: `histogram_quantile(0.95, ...)` over the request-duration histogram.
- **Traffic**: `sum(rate(...requests_total[5m]))`.
- **Errors**: the recorded 5xx ratio.
- **Saturation**: host CPU from node-exporter.

Golden signals tell you something is wrong. The SLO and error budget tell you whether it is wrong *enough to act on*. You want both.

## Why Prometheus and Grafana

They are the de facto open-source standard, run anywhere, and cost nothing in licensing. The concepts (SLI, SLO, error budget, burn rate) are identical on managed platforms like New Relic or Datadog. Learn them here on tools you can run on your laptop, and they transfer directly.
