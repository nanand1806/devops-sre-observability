# The bucket that will hold Terraform state files.
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
}

# Versioning lets you recover a previous state file if one is corrupted
# or a bad apply needs to be rolled back. This is not optional for state.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state at rest. State files can contain secrets, so this matters.
# AES256 (SSE-S3) needs no key management. Swap to aws:kms for a CMK.
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# State must never be public. Block every path to a public object.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking. Terraform writes a lock item here so
# two people cannot apply at the same time and corrupt state. The hash key
# must be named LockID; pay-per-request means you pay only for locks taken.
resource "aws_dynamodb_table" "locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
