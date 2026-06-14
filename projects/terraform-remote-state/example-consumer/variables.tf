variable "aws_region" {
  description = "AWS region (must match the region of your state bucket)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used in the demo SSM parameter path"
  type        = string
  default     = "demo"
}
