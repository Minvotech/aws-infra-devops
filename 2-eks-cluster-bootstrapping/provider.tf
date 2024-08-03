terraform {
  #required_version = "1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0" # Optional but recommended in production
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      #version = "2.4.1"
      version = "2.6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.18.0"
    }
  }
  backend "s3" {
    bucket         = "owais-tfstate-prod"        # REPLACE WITH YOUR BUCKET NAME
    key            = "eks-prod-bootstrapping/terraform.tfstate" # Replace with your statefile object path
    region         = "ca-central-1"
    dynamodb_table = "owais-tfstate-locking-prod"
    encrypt        = true
    profile        = "default"
  }



}


data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}
#
data "aws_caller_identity" "current" {}

provider "kubectl" {
  alias = "eks"
  config_context_cluster = data.aws_eks_cluster.eks.name
}


provider "kubernetes" {
  #host = data.aws_eks_cluster.cluster.endpoint
  host = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.eks.certificate_authority.0.data
  )

  #cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1" 
    #"client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
  }
}

provider "aws" {
  region = "ca-central-1"
}
provider "helm" {
  kubernetes {
#    config_context_cluster = data.aws_eks_cluster.eks.name
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
      command     = "aws"
    }
  }
}
