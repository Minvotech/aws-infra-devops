resource "aws_kms_key" "eks_secrets_encryptor" {
  description  = "KMS key used for encrypting secrets in eks cluster"
  key_usage    = "ENCRYPT_DECRYPT"
  multi_region = false

  tags = {
    "created_by" = "terraform"
    "used_for"   = "eks_secrets"
  }
}

resource "aws_kms_alias" "eks_secrets_encryptor" {
  name          = "alias/${var.cluster_name}-kms-3"
  target_key_id = aws_kms_key.eks_secrets_encryptor.id
}