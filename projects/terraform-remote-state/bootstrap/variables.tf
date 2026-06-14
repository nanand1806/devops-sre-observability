variable "aws_region" {
  description = "AWS region for the state bucket and lock table"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used for tagging"
  type        = string
  default     = "demo"
}

variable "state_bucket_name" {
  description = "Globally unique name for the S3 bucket that stores Terraform state. S3 bucket names are global, so pick something unique to you."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "Bucket name must be 3-63 chars, lowercase letters, numbers, dots, and hyphens."
  }
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  type        = string
  default     = "terraform-locks"
}
