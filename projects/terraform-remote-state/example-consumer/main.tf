# A trivial resource so there is something real in state to store remotely.
# After you migrate to the S3 backend, this resource's state lives in S3,
# and a lock is taken in DynamoDB on every plan and apply.
resource "aws_ssm_parameter" "demo" {
  name        = "/${var.project_name}/remote-state-demo"
  description = "Demonstrates Terraform state stored in S3"
  type        = "String"
  value       = "If you can read this from another machine, remote state works."
}
