provider "aws" {
  profile = "default"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name
  # for previnting bucket from being deleted unless all of its objects is deleted
  force_destroy = true

  # for preventing an intended destroy 
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  # for preventing an intended destroy 
  lifecycle {
    prevent_destroy = true
  }
}