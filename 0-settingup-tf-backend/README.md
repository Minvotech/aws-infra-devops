# TOC
- [Creating the remote backend for the first time](#steps-for-creating-tf-backend)
- [Bootstrapping step for using the created remote backend for tracking itself](#tracking-the-backend-terraform-code-with-itself)
- [Use this remote backend in your infrastracture at general](#use-the-below-block-for-tracking-your-infrastracture-state-file-remotly)
- [Destroying backend (hopefully something you will never need but just in case)  :rotating_light::fire::fire:](#destroying-your-backend)

## Steps for creating tf backend
1. For the first time creation of the remote backend (s3, and dynamo table) you should comment out the backend block in the backend.tf file
2. Initialize your code `terraform init` (this will initialze your terrafrom using local backend)
3. Then run plan `terraform plan`
4. And apply your configs `terraform apply -auto-approve`

## Tracking the backend terraform code with itself
1. un-comment out the backend block in backend.tf file
2. terraform init (approve uploading your local backend)
3. Now your code is tracked with reomte backend 

## Use the below block for tracking your infrastracture state file remotly
- keep in mind to change the key for different parts of your infrastracture

```hcl
terraform {
  backend "s3" {
    bucket         = "<s3-bucket-name>" # REPLACE WITH YOUR BUCKET NAME
    key            = "<any-part-of-ur-infra>/terraform.tfstate" # Replace with your statefile object key
    region         = "ca-central-1"
    dynamodb_table = "<dynamodb_table_name>"
    encrypt        = true
    profile        = "your-profile"
  }
}
```

- Example backend block for eks cluster
```hcl
terraform {
  backend "s3" {
    bucket         = "minvo-tfstate-dev" # REPLACE WITH YOUR BUCKET NAME
    key            = "eks-dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-state-locking-dev"
    encrypt        = true
    profile        = "default"
    #role_arn = "arn:aws:iam::123456789f12:role/my-terraform-role"
  }
}
```

## Destroying your backend
- :rotating_light::fire::fire: comment out the below part in both `s3 and dynamodb` in `main.tf` file
```
  lifecycle {
    prevent_destroy = true
  }
```

- Then do your plan and apply commands