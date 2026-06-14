# ECS Fargate, explained

Companion notes for the [`ecs-fargate-terraform`](../projects/ecs-fargate-terraform) project. Read this if the terms in the code are new to you.

## The problem it solves

You have a container and you want it running reliably on AWS without managing any servers. You want it to scale, restart if it crashes, sit behind a load balancer, and not be directly exposed to the internet. That is exactly what this stack gives you.

## The pieces, in plain terms

**ECS (Elastic Container Service)** is AWS's container orchestrator. It decides where your containers run and keeps the right number of them alive.

**Fargate** is the "no servers" mode of ECS. Instead of running and patching EC2 instances to host containers, you hand AWS a container and a CPU/memory size, and it runs it for you. You pay per task, per second.

**Task definition** is the blueprint for one running unit: which image, how much CPU and memory, which ports, where logs go. Think of it as the spec.

**Service** keeps N copies of that task running. If a task dies, the service starts a new one. If you change `desired_count`, it scales.

**Application Load Balancer (ALB)** is the front door. It takes HTTP requests and spreads them across healthy tasks. It also runs health checks and stops sending traffic to a task that fails them.

**Target group** is the ALB's list of "where can I send traffic." With Fargate we use `target_type = "ip"` because each task gets its own IP in the VPC.

## Why tasks live in private subnets

A common beginner setup puts everything in public subnets. It works, but it means your application tasks have public IPs and are reachable from the internet if a security group is misconfigured.

The pattern here is safer:

- Only the ALB is public.
- Tasks sit in private subnets with no public IP.
- The task security group only allows traffic coming from the ALB security group, nothing else.
- Tasks still need to reach out (to pull the image and send logs), so a NAT gateway gives them outbound-only internet access.

This is "the internet can reach the front door, but it cannot reach the rooms behind it."

## The two IAM roles people confuse

- **Execution role**: used by the ECS infrastructure to pull your image and write your logs. It needs the managed `AmazonECSTaskExecutionRolePolicy`.
- **Task role**: assumed by your application code if it calls AWS APIs (for example reading from S3). It starts empty here. Keep it scoped to only what the app needs.

If your app cannot read an SSM parameter or an S3 bucket, the task role is usually what you forgot.

## How a request flows

1. User hits the ALB DNS name on port 80.
2. ALB picks a healthy task from the target group.
3. ALB forwards the request to that task's IP on the container port.
4. The task responds; the ALB returns it to the user.
5. The ALB keeps health-checking `/`. A task that stops returning 2xx/3xx is pulled out of rotation.

## Going deeper

- **HTTPS**: add an ACM certificate, a 443 listener, and redirect 80 to 443.
- **Autoscaling**: attach Application Auto Scaling to the service and scale on CPU, memory, or ALB request count per target.
- **Zero-downtime deploys**: ECS rolling deployments replace tasks gradually; for safer rollouts use CodeDeploy blue/green.
- **Connection limits**: a database behind this will exhaust connections under load. Put a pooler (PgBouncer, RDS Proxy) between the app and the database.
- **Cost**: the NAT gateway is often the surprise line item. VPC endpoints for ECR, S3, and CloudWatch Logs can remove most NAT data charges for image pulls and logging.
