resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eksClusterRole.arn
  version = var.kubernetes_version

  vpc_config {
    subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
    # subnet_ids = var.subnet_ids
    endpoint_public_access = true
    endpoint_private_access = true
  }

  # Enable encryption at rest for k8s secrets
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets_encryptor.arn # Replace this with the KMS key ARN for encryption 
    }
    resources = ["secrets"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_kms_key.eks_secrets_encryptor,
  ]
}