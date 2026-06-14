variable "aws_region" {
  description = "AWS region for the home trail and regional resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used to prefix and tag resources"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for the CloudTrail log group"
  type        = number
  default     = 90
}

variable "required_tag_key" {
  description = "Tag key that the required-tags Config rule enforces"
  type        = string
  default     = "Project"
}
