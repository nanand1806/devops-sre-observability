output "alb_dns_name" {
  description = "Public DNS name of the load balancer. Open this in a browser."
  value       = aws_lb.this.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}
