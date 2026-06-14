# DevOps, SRE & Observability

[![CI](https://github.com/nanand1806/devops-sre-observability/actions/workflows/ci.yml/badge.svg)](https://github.com/nanand1806/devops-sre-observability/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Production-grounded reference implementations for DevOps, SRE, and observability, written to be read and reused. Each project is self-contained, runnable, and documented for both newcomers and experienced engineers.

I'm Naveen Anand, a cloud and DevOps leader and freelance cloud solution architect (Azure + AWS). I maintain this repo as a public lab and a companion to my writing. Profile: [github.com/nanand1806](https://github.com/nanand1806).

---

## Projects

| Project | Cloud | Stack | What it shows | Status |
|---|---|---|---|---|
| [ecs-fargate-terraform](projects/ecs-fargate-terraform) | ![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazonwebservices&logoColor=FF9900) | Terraform | A containerized service on ECS Fargate behind an ALB, in private subnets with NAT egress | Ready |
| [terraform-remote-state](projects/terraform-remote-state) | ![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazonwebservices&logoColor=FF9900) | Terraform | S3 + DynamoDB remote state with locking | Ready |
| [aws-landing-zone](projects/aws-landing-zone) | ![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazonwebservices&logoColor=FF9900) | Terraform | CloudTrail, AWS Config rules, GuardDuty, account-wide guardrails | Ready |
| [azure-landing-zone](projects/azure-landing-zone) | ![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoftazure&logoColor=white) | Terraform | Hub-spoke networking, governance policy, central Log Analytics, Key Vault | Ready |
| [newrelic-golden-signals](projects/newrelic-golden-signals) | ![New Relic](https://img.shields.io/badge/New%20Relic-1CE783?logo=newrelic&logoColor=black) | Terraform | Golden-signal NRQL alerts routed to Slack and Teams via a workflow | Ready |
| [observability-starter](projects/observability-starter) | ![Cloud-agnostic](https://img.shields.io/badge/Cloud--agnostic-555555) | Prometheus, Grafana | Golden-signal dashboard and multi-window SLO burn-rate alerts, runnable with Docker | Ready |

---

## Companion writing

Each project pairs with a concept write-up in [`docs/`](docs) aimed at engineers entering the field, with a "going deeper" layer for the experienced. Long-form articles are published on [Medium (@anandnaveen)](https://medium.com/@anandnaveen).

---

## Repo standards

Everything here is held to a consistent bar:

- **No real-world data.** Every account ID, ARN, hostname, and name is a placeholder (`123456789012`, `example.com`). Nothing references any employer or client system.
- **Clean reference implementations.** Projects are written from scratch as generic references, not exported from private work.
- **Secret scanning.** [gitleaks](https://github.com/gitleaks/gitleaks) runs in CI and is recommended as a pre-commit hook.
- **Validated IaC.** `terraform fmt`, `terraform validate`, and formatting checks run on every push.
- **Self-contained projects.** Each `projects/*` folder has its own README, architecture diagram, prerequisites, run steps, and teardown.

---

## Using these projects

```bash
git clone https://github.com/nanand1806/devops-sre-observability.git
cd devops-sre-observability/projects/ecs-fargate-terraform
# follow the project README
```

Cloud resources cost money. Each project documents what it provisions and how to tear it down. Always run the teardown step when you are done.

---

## Security

This repo is hardened so nothing sensitive ever ships and nobody has more access than they need:

- **No secrets in the repo.** All account IDs, ARNs, keys, hostnames, and webhook URLs are placeholders. Real credentials are passed at runtime via environment variables.
- **Secret scanning + push protection** (GitHub native) block secrets at push time.
- **gitleaks** runs in CI on every push and pull request as a second layer.
- **`main` is protected.** Changes go through a pull request, CI (gitleaks + Terraform validate) must pass before merge, and force-pushes and branch deletion are blocked.
- **Least-privilege CI.** The workflow `GITHUB_TOKEN` is read-only.
- **Pinned actions.** Third-party GitHub Actions are pinned to commit SHAs, not movable tags, to prevent supply-chain tampering.
- **Dependabot** alerts and automated security updates are enabled.

Found something that looks like a security issue? Open an issue or reach out via [LinkedIn](https://www.linkedin.com/in/anandnaveen/).

---

## License

[MIT](LICENSE). Use, adapt, and learn from anything here.
