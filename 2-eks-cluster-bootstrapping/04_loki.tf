# Creating the 3 s3 buckets

resource "aws_s3_bucket" "loki_buckets" {

  for_each = var.loki_buckets
  bucket = each.value
  tags = {
    name = each.value
    cluster = var.cluster_name
  }
  
  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_versioning" "loki_bucket_versioning" {
  for_each = aws_s3_bucket.loki_buckets
  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_encryption_config" {
  for_each = aws_s3_bucket.loki_buckets
  bucket = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Define the IAM role
resource "aws_iam_role" "loki_stack_role" {
  name = "eks-prod-loki-role-prod"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::211337202074:oidc-provider/oidc.eks.ca-central-1.amazonaws.com/id/ABD04ACDA2CDD5506EF59C42DB251210"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.ca-central-1.amazonaws.com/id/ABD04ACDA2CDD5506EF59C42DB251210:aud": "sts.amazonaws.com",
                    "oidc.eks.ca-central-1.amazonaws.com/id/ABD04ACDA2CDD5506EF59C42DB251210:sub": "system:serviceaccount:logging:loki-sa-prod"
                }
            }
        }
    ]
}
EOF
}

# Define the IAM role policy
resource "aws_iam_role_policy" "loki_stack_policy" {
  name   = "eks-prod-loki-policy-prod"
  role   = aws_iam_role.loki_stack_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::owais-eks-prod-loki-*",
        "arn:aws:s3:::owais-eks-prod-loki-*/*"
      ]
    }
  ]
}
EOF
}



# installing the helm release 
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = var.namespace_logging #"cluster-bootstrapping"
  version    = "5.41.4"

  values = [
    file("${path.module}/loki-ssd/loki-ssd-our-values.yml")
  ]
  depends_on = [
    helm_release.kong,
    helm_release.prometheus,
    aws_iam_role_policy.loki_stack_policy,
    aws_s3_bucket_server_side_encryption_configuration.loki_encryption_config
  ]
}
