# Account-wide guardrails. These apply to the whole account, not a single
# resource, which is exactly what makes them landing-zone controls.

# Strong password policy for IAM users.
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
}

# Block public access for every bucket in the account, even if an
# individual bucket policy tries to allow it. This is the account-level
# safety net against accidental public S3 data.
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
