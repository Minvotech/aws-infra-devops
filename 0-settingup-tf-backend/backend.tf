terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  backend "s3" {
    bucket         = "owais-tfstate-prod"        # REPLACE WITH YOUR BUCKET NAME
    key            = "tfstate/terraform.tfstate" # Replace with your statefile object path
    region         = "ca-central-1"
    dynamodb_table = "owais-tfstate-locking-prod"
    encrypt        = true
    profile        = "default"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
  }
}