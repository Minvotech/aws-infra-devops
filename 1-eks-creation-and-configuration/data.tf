data "aws_eks_cluster" "eks_cluster" {
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.eks_cluster]
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.eks_cluster]
}

data "aws_caller_identity" "current" {}
