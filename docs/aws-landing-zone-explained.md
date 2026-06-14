# AWS landing zones, explained

Companion notes for the [`aws-landing-zone`](../projects/aws-landing-zone) project. Pair this with the [Azure version](azure-landing-zone-explained.md) to see the same ideas in both clouds.

## The idea

A landing zone is the governed foundation you lay down before any application is deployed, so every workload arrives in an account that is already audited, monitored, and guard-railed. Without it, each team's account drifts into its own ungoverned shape. With it, "secure and compliant" is the default state, not a cleanup project.

## The four layers in this project

### 1. Audit: CloudTrail

CloudTrail records every API call in the account: who did what, when, from where. This is the flight recorder. If something breaks or is breached, the trail is how you reconstruct events.

Key choices in the project and why:

- **Multi-region**: capture activity in every region, not just one, so nothing hides in an unused region.
- **Log file validation**: CloudTrail signs its logs so you can prove they were not tampered with.
- **To S3 and CloudWatch Logs**: S3 is durable long-term storage; CloudWatch Logs lets you alert on events in near real time.

### 2. Compliance: AWS Config

CloudTrail tells you what *happened*. Config tells you what *exists* and whether it is still compliant. It records the configuration of resources over time and evaluates them against **rules**.

This project enables three managed rules: every resource must carry a required tag, no S3 bucket may be publicly readable, and EBS volumes must be encrypted. A resource that violates a rule is flagged non-compliant. Config is the AWS analogue of Azure Policy, with one difference worth knowing: Azure Policy can *prevent* a non-compliant resource from being created (deny), while Config by default *detects and reports* it. To prevent actions in AWS you use Service Control Policies (which need Organizations).

### 3. Threat detection: GuardDuty

GuardDuty continuously analyzes CloudTrail, VPC flow logs, and DNS queries using threat intelligence and machine learning. It surfaces things like credential exfiltration, crypto-mining, and calls from known-bad IPs. It is one resource to enable and needs no agents.

### 4. Account-wide guardrails

Two settings here apply to the entire account:

- **S3 account public access block**: even if someone writes a bucket policy that tries to make a bucket public, this account-level switch overrides it. It is the single most effective control against accidental S3 data leaks.
- **IAM password policy**: enforces strong passwords for all IAM users.

These are "blast radius" controls. They do not protect one resource; they raise the floor for the whole account.

## The bucket policy, briefly

The central log bucket has a policy that does four things: lets CloudTrail and Config write to their own prefixes, restricts those writes to this specific trail and account (so another account cannot dump logs into your bucket), and denies any access that does not use TLS. Locking down where the logs live is as important as collecting them.

## How this maps to Azure

| AWS | Azure |
|---|---|
| Account | Subscription |
| CloudTrail | Activity Log + diagnostic settings |
| AWS Config | Azure Policy (audit effects) |
| Service Control Policy | Azure Policy (deny effects) |
| GuardDuty | Microsoft Defender for Cloud |
| Security Hub | Defender for Cloud / Sentinel |
| S3 account public access block | Storage account network rules + policy |
| Control Tower | Azure landing zone accelerator |

Same goals in both clouds: record everything, check compliance continuously, detect threats, and set account-wide floors. Learn the pattern once and the service names are just translation.

## Single account vs multi-account

This project is a single-account baseline because that is what most people can deploy and learn on. The enterprise version uses **AWS Organizations**: a management account at the top, a dedicated log-archive account, an audit account, and workload accounts underneath, all governed centrally with SCPs and set up quickly with **AWS Control Tower**. The controls are the same ideas, applied across many accounts instead of one.
