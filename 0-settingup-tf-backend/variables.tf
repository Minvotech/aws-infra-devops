variable "region" {
  type    = string
  default = "ca-central-1"
}

variable "s3_bucket_name" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}
