# GuardDuty is managed threat detection. It continuously analyzes
# CloudTrail, VPC flow logs, and DNS logs for malicious activity. Enabling
# it is one resource and is part of any serious account baseline. Extra
# protections (S3, EKS, malware) are added with aws_guardduty_detector_feature.
resource "aws_guardduty_detector" "this" {
  enable = true
}
