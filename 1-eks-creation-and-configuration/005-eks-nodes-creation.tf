resource "aws_eks_node_group" "main_nodegroup" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-nodeGroup-1"
  node_role_arn   = aws_iam_role.eksWorkerNodeRole.arn
  subnet_ids      = module.vpc.private_subnets #var.subnet_ids_asg
  instance_types  = var.instance_types

  version = var.kubernetes_version
  ami_type = var.ami_type
  
  disk_size      = var.eks_node_storage
  #associate_public_ip_address = false
  scaling_config {
    desired_size = var.ng_ndoes_desired_size
    max_size     = var.ng_ndoes_max_size
    min_size     = var.ng_ndoes_min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}