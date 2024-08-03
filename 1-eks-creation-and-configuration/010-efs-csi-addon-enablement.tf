##--------- creating the required permissions and configuring IRSA 
# generate a trust policy json document
data "aws_iam_policy_document" "eks_efs_csi_role_assume_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [local.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_cluster_issuer_url}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-*"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_cluster_issuer_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Create role with a trust relation ship (trust policy)
resource "aws_iam_role" "eks_efs_csi_role" {
  name               = "${var.cluster_name}_AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.eks_efs_csi_role_assume_role_policy_document.json
}

# attach policy to the role
resource "aws_iam_role_policy_attachment" "AmazonEKS_EFS_CSI_DriverRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.eks_efs_csi_role.name
}

## creating two service accounts
resource "null_resource" "efs-csi-serviceaccounts" {
  # Run after helm_release 
  triggers = {
    role = aws_iam_role.eks_efs_csi_role.name
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/efs-csi/efs-csi-serviceaccounts.yml"
  }

  depends_on = [aws_iam_role.eks_efs_csi_role]
}


## ------------- deploy the efs-csi-driver using helm
# helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
# helm repo update aws-efs-csi-driver
# helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver
# --set controller.serviceAccount.create=false \
# --set controller.serviceAccount.name=efs-csi-controller-sa 
# resource "helm_release" "aws-efs-csi-driver" {
#   name       = "aws-efs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   namespace  = "kube-system"

#   set {
#     name  = "controller.serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "controller.serviceAccount.name"
#     value = "efs-csi-controller-sa"
#   }

#   set {
#     name  = "node.serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "node.serviceAccount.name"
#     value = "efs-csi-node-sa"
#   }

#   depends_on = [null_resource.efs-csi-serviceaccounts]
# }
