resource "aws_ec2_tag" "karpenter_discovery_tags" {
  #for_each = toset(module.vpc.private_subnets)
  for_each = { for i, v in module.vpc.private_subnets : i => v }
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name

  # depends_on = [aws_ec2_tag.karpenter_tags]
}

resource "aws_ec2_tag" "karpenter_discovery_tags_sq" {
  resource_id = data.aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name

  depends_on = [aws_eks_node_group.main_nodegroup]
}




##------- create sqs
resource "aws_sqs_queue" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter"
  tags = {
    Name = "${var.cluster_name}-karpenter"
  }
}


##------ Create a service account
resource "kubernetes_service_account" "karpetner_sa_1" {
  metadata {
    name      = "karpenter"
    namespace = "karpenter"
    annotations = {
      "eks.amazonaws.com/role-arn"     = "${module.iam_assumable_role_karpenter.iam_role_arn}"
      "app.kubernetes.io/managed-by"   = "Helm"
      "meta.helm.sh/release-name"      = "karpenter"
      "meta.helm.sh/release-namespace" = "karpenter"
    }
  }
  depends_on = [ kubernetes_namespace.bootstrapping-namespaces ]
}


##------------ creating karpenter using helm 
resource "null_resource" "karpenter_upgrade2" {
  triggers = {
    karpenter_version          = var.karpenter_version
    karpenter_iam_role_arn     = module.iam_assumable_role_karpenter.iam_role_arn
    cluster_name               = var.cluster_name
    karpenter_namespace        = var.karpenter_namespace
    cluster_endpoint           = aws_eks_cluster.eks_cluster.endpoint
    karpenter_target_nodegroup = var.karpenter_target_nodegroup
    instance_profile_name      = var.instanceprofile_name
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }

  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --cluster ${var.cluster_name} --approve"
    environment = {
      AWS_PROFILE = var.aws_profile
    }
  }

  provisioner "local-exec" {
    command = "helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --namespace ${var.karpenter_namespace} --version ${var.karpenter_version} --set serviceAccount.create=false --set serviceAccount.name=karpenter --set settings.aws.clusterName=${var.cluster_name} --set settings.aws.clusterEndpoint=${data.aws_eks_cluster.eks_cluster.endpoint}  --set settings.aws.interruptionQueueName=${var.cluster_name} --wait"
    environment = {
      AWS_PROFILE = var.aws_profile
    }
  }
  depends_on = [
    aws_eks_node_group.main_nodegroup,
    aws_ec2_tag.karpenter_discovery_tags_sq
    ]
}

# resource "null_resource" "karpenter_crds" {
#   triggers = {
#     cluster_name     = var.cluster_name
#     cluster_endpoint = data.aws_eks_cluster.eks_cluster.endpoint
#   }
#   depends_on = [null_resource.karpenter_upgrade]

  # provisioner "local-exec" {
  #   command = "kubectl apply -f ${path.module}/karpenter-crds/nodepool-main.yml --namespace ${var.karpenter_namespace}"
  #   environment = {
  #     AWS_PROFILE = var.aws_profile
  #   }
  # }
  # provisioner "local-exec" {
  #   command = "kubectl apply -f ${path.module}/karpenter-crds/nodeclass-main.yml --namespace ${var.karpenter_namespace}"
  #   environment = {
  #     AWS_PROFILE = var.aws_profile
  #   }
  # }
  # provisioner "local-exec" {
  #   command = "kubectl apply -f ${path.module}/karpenter-crds/nodepool-eks.yml --namespace ${var.karpenter_namespace}"
  #   environment = {
  #     AWS_PROFILE = var.aws_profile
  #   }
  # }
  # provisioner "local-exec" {
  #   command = "kubectl apply -f ${path.module}/karpenter-crds/nodeclass-eks.yml --namespace ${var.karpenter_namespace}"
  #   environment = {
  #     AWS_PROFILE = var.aws_profile
  #   }
  # }

  #depends_on = [null_resource.karpenter_upgrade]
# }