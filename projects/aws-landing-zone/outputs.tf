output "logging_bucket" {
  description = "Central S3 bucket holding CloudTrail and Config logs"
  value       = aws_s3_bucket.logging.id
}

output "cloudtrail_name" {
  description = "Name of the multi-region CloudTrail"
  value       = aws_cloudtrail.this.name
}

output "cloudtrail_log_group" {
  description = "CloudWatch Logs group receiving CloudTrail events"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "config_recorder" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.this.name
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.this.id
}
