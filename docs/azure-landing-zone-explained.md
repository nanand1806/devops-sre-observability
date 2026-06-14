# Azure landing zones, explained

Companion notes for the [`azure-landing-zone`](../projects/azure-landing-zone) project. Read this if "landing zone" sounds like jargon.

## The idea in one sentence

A landing zone is the prepared, governed foundation you build *before* anyone deploys an application, so that every workload "lands" in a consistent, secure, well-organized environment instead of a free-for-all.

## Why you need one

Without a foundation, each team creates resources however they like: random naming, any region, no central logging, secrets in code, networks that either can't talk or are wide open. Six months in you have an unmanageable sprawl nobody fully understands.

A landing zone decides the rules up front and encodes them:

- **Structure**: how resources are grouped (resource groups, and at larger scale, management groups and subscriptions).
- **Networking**: how environments connect, usually hub-and-spoke.
- **Governance**: what is and isn't allowed, enforced by policy.
- **Observability**: where logs and metrics go.
- **Security**: where secrets live and who can reach what.

## Hub and spoke, in plain terms

Picture an airport. The **hub** is the central terminal that holds shared services everyone needs: connectivity to on-premises, firewalls, DNS. Each **spoke** is a workload's own network, connected to the hub but isolated from other spokes.

Why not one big flat network? Because isolation limits blast radius. A compromised or misbehaving workload in one spoke cannot freely reach another. Shared services live once in the hub instead of being rebuilt in every spoke. The two are joined by **VNet peering**, which must be created on both sides to work.

## Resource groups: platform vs workload

This project splits resources into two groups on purpose:

- **Platform** holds shared, long-lived services (the hub network, central logging, Key Vault). The platform team owns it.
- **Workload** is where app teams deploy. They get rights here without touching the platform layer.

This separation is about ownership and blast radius, the same instinct as putting application tasks in private subnets in the AWS ECS project.

## Governance with Azure Policy

A wiki page that says "only deploy in Central India" is a suggestion. **Azure Policy** is enforcement. You assign a policy at a scope (resource group, subscription, or management group) and Azure evaluates every resource against it.

This project assigns the built-in "Allowed locations" policy at the subscription scope. Try to create a resource in a disallowed region and Azure refuses. Policies can also *audit* (flag but allow) or *deploy if not exists* (auto-remediate). Grouping several policies together makes an **initiative**.

## Central logging

Every resource can emit diagnostics. Sending them all to one **Log Analytics workspace** means you query everything in one place with one language (KQL), set alerts centrally, and retain logs on the platform team's terms rather than per-team guesswork.

## Secrets: Key Vault with RBAC

Secrets do not belong in code or config files. **Key Vault** stores secrets, keys, and certificates. The modern access model is **RBAC** (grant roles like "Key Vault Secrets User") rather than the older per-vault access policies. This project enables RBAC authorization for that reason.

## How this maps to AWS

If you know AWS, the analogies help:

| Azure | AWS |
|---|---|
| Subscription | Account |
| Resource group | (no exact match; closest is tags / stacks) |
| Hub-spoke VNet peering | Transit Gateway / VPC peering |
| NSG | Security group / NACL |
| Azure Policy | SCPs + AWS Config rules |
| Log Analytics | CloudWatch Logs |
| Key Vault | Secrets Manager / SSM Parameter Store |

The concepts are the same: isolate, govern, centralize logging, protect secrets. Only the service names change. That portability is the whole point of learning the patterns, not just one cloud's buttons.
