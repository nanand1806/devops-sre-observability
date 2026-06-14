# GuardDuty is managed threat detection. It continuously analyzes
# CloudTrail, VPC flow logs, and DNS logs for malicious activity. Enabling
# it is one resource and is part of any serious account baseline.
resource "aws_guardduty_detector" "this" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
  }
}
