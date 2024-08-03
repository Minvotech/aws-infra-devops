# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Role for ServiceAccount to use
module "iam_assumable_role_karpenter" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "4.7.0"
  create_role                    = true
  role_name                      = "karpenter-controller-${var.cluster_name}"
  provider_url                   = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_fully_qualified_subjects  = ["system:serviceaccount:${var.karpenter_namespace}:karpenter"]
}


# Based on https://karpenter.sh/docs/getting-started/cloudformation.yaml
resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter-policy-${var.cluster_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:GetInstanceProfile",
          "iam:CreateInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DeleteLaunchTemplate",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "pricing:GetProducts",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },

      {
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "sqs:ReceiveMessage"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.cluster_name}-karpenter"
      },
      {
        Action = [
          "iam:PassRole",
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter_node.arn
      }
    ]
  })
}

resource "aws_iam_role" "karpenter_node" {
  name = "karpenter-node-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
     var.ssm_instance_policy,
     var.karpenter_node_kms_decrypt_lzaz-ssm,
     var.vaultUnsealKMSPolicy

  ]
}

#resource "aws_iam_instance_profile" "karpenter_node" {
#  name = "KarpenterNodeInstanceProfile-${var.instanceprofile_name}"
#  role = aws_iam_role.karpenter_node.name
#}


## edit aws-auth file using eksctl
resource "null_resource" "modify_aws_auth2" {
  triggers = {
    iam_role_arn = aws_iam_role.karpenter_node.arn
    cluster      = var.cluster_name
    aws_profile  = var.aws_profile
  }

  provisioner "local-exec" {
    on_failure = fail
    when       = create
    environment = {
      AWS_PROFILE = var.aws_profile
    }
    #interpreter = ["/bin/bash", "-c"]
    command = <<EOT
            eksctl create iamidentitymapping  --username system:node:{{EC2PrivateDNSName}} --cluster ${self.triggers.cluster} --arn ${self.triggers.iam_role_arn} --group system:bootstrappers  --group system:nodes
        EOT
  }

  provisioner "local-exec" {
    on_failure = fail
    when       = destroy
    environment = {
      AWS_PROFILE = self.triggers.aws_profile
    }
    #interpreter = ["/bin/bash", "-c"]
    command = <<EOT
            eksctl delete iamidentitymapping --cluster ${self.triggers.cluster} --arn ${self.triggers.iam_role_arn}
        EOT
  }

  depends_on = [
    aws_iam_role.karpenter_node,
    aws_eks_node_group.main_nodegroup, null_resource.karpenter_upgrade2
  ]
}

