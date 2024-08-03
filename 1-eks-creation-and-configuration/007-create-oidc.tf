data "tls_certificate" "aws_eks_tls_cert" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_cluster_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.aws_eks_tls_cert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.aws_eks_tls_cert.url

  depends_on = [aws_eks_cluster.eks_cluster]
}