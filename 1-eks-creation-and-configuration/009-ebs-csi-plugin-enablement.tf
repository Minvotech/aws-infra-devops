locals {
  oidc_cluster_issuer_url = replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn   = aws_iam_openid_connect_provider.eks_cluster_oidc.arn
}

##--- creating policy
# the below data is for just generating a json document inplace
data "aws_iam_policy_document" "AmazonEKS_EBS_CSI_DriverRolePolicy_document" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "AmazonEKS_EBS_CSI_DriverRolePolicy" {
  name   = "${var.cluster_name}_AmazonEKS_EBS_CSI_DriverRolePolicy"
  policy = data.aws_iam_policy_document.AmazonEKS_EBS_CSI_DriverRolePolicy_document.json
}


##--------- create role
# For_just_generating an iam assume policy in json 
data "aws_iam_policy_document" "eks_ebs_csi_role_assume_role_policy_document" {
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
      test     = "StringEquals"
      variable = "${local.oidc_cluster_issuer_url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

# create role
resource "aws_iam_role" "eks_ebs_csi_role" {
  name               = "${var.cluster_name}_AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.eks_ebs_csi_role_assume_role_policy_document.json
}

# attach policy to the role
resource "aws_iam_role_policy_attachment" "AmazonEKS_EBS_CSI_DriverRolePolicy" {
  policy_arn = aws_iam_policy.AmazonEKS_EBS_CSI_DriverRolePolicy.arn
  role       = aws_iam_role.eks_ebs_csi_role.name
}


##------- Enabling the pluging using ekstl
resource "null_resource" "ebs_csi_driver" {
  provisioner "local-exec" {
    command = "eksctl create addon --name aws-ebs-csi-driver --cluster ${var.cluster_name} --service-account-role-arn ${aws_iam_role.eks_ebs_csi_role.arn} --force"
    environment = {
      AWS_PROFILE = var.aws_profile
    }
  }
  depends_on = [ aws_eks_node_group.main_nodegroup ]
}

resource "null_resource" "ebs_csi_driver_delete" {

  triggers = {
    cluster_name = var.cluster_name
    aws_profile  = var.aws_profile
  }

  provisioner "local-exec" {
    when    = destroy
    command = "eksctl delete addon --name aws-ebs-csi-driver --cluster ${self.triggers.cluster_name}"
    environment = {
      AWS_PROFILE = self.triggers.aws_profile
    }
  }

}
