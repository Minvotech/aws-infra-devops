resource "kubernetes_namespace" "bootstrapping-namespaces" {

  for_each = var.namespaces
  metadata {
    name = each.value
  }

  depends_on = [aws_eks_node_group.main_nodegroup]
}