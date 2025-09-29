# Prod environment root module
terraform {
  required_version = ">= 1.6.0"
  backend "s3" {
    bucket         = "CHANGE_ME_STATE_BUCKET"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "CHANGE_ME_LOCK_TABLE"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile != "" ? var.aws_profile : null
}

module "example" {
  source      = "../modules/example"
  bucket_name = var.bucket_name
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  default     = ""
  description = "Optional AWS CLI profile to use"
}

variable "bucket_name" {
  type        = string
  default     = "my-example-bucket-prod-CHANGE"
  description = "Example bucket name"
}

output "bucket_id" {
  value = module.example.bucket_id
}
