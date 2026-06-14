terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # The remote backend is intentionally NOT defined here so this example
  # validates with local state out of the box. To use the remote backend,
  # copy backend.tf.example to backend.tf, fill in your values, and run:
  #   terraform init -migrate-state
}

provider "aws" {
  region = var.aws_region
}
