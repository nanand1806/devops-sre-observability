output "state_bucket" {
  description = "Name of the S3 bucket holding Terraform state"
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "Name of the DynamoDB lock table"
  value       = aws_dynamodb_table.locks.name
}

# Copy this block into any project that should use the remote backend.
output "backend_config" {
  description = "Ready-to-paste backend block for consumer projects"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.state.id}"
        key            = "PROJECT_NAME/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.locks.name}"
        encrypt        = true
      }
    }
  EOT
}
