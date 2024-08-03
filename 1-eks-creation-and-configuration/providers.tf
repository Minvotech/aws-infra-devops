terraform {
  # required_version = "~> 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.1" #"4.64.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

  }
}

provider "aws" {
  #profile = var.aws_profile
  region = var.region
}

# authenticating to our cluster
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks_cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
# }

# data "aws_caller_identity" "current" {}

provider "kubectl" {
  alias                  = "eks"
  config_context_cluster = data.aws_eks_cluster.eks_cluster.name
}


provider "kubernetes" {
  #host = data.aws_eks_cluster.cluster.endpoint
  host = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.eks_cluster.certificate_authority.0.data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    #"client.authentication.k8s.io/v1alpha1"
    command = "aws"
    args    = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster.name]
  }
}

provider "helm" {
  kubernetes {
    #    config_context_cluster = data.aws_eks_cluster.eks_cluster.name
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster.name]
      command     = "aws"
    }
  }
}
