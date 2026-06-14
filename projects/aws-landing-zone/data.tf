data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  name       = "${var.project_name}-${var.environment}"
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
  trail_name = "${local.name}-trail"

  # Built as a string (not a resource reference) so the bucket policy can
  # restrict access to this trail without creating a dependency cycle
  # between the trail and the bucket it writes to.
  trail_arn = "arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"
}
