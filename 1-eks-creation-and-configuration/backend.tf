terraform {
  backend "s3" {
    bucket         = "owais-tfstate-prod"        # REPLACE WITH YOUR BUCKET NAME
    key            = "tfstate/terraform.tfstate" # Replace with your statefile object path
    region         = "ca-central-1"
    dynamodb_table = "owais-tfstate-locking-prod"
    encrypt        = true
    profile        = "default"
  }

}