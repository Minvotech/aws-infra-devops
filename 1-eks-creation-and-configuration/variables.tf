##------ region
variable "region" {
  type    = string
  default = "ca-central-1"
}

variable "aws_profile" {
  type = string
}

##------ cluster 
variable "cluster_name" {
  description = "Name of the EKS Cluster."
  type        = string
}

##----- kubernetes_version
variable "kubernetes_version" {
  type    = string
}
##-----aws-ebs-csi-driver-version
variable "ebs_csi_driver_version" {
  type    = string
}
##---ami_type
variable "ami_type" {
  type    = string
}

## ------- private-subnets

 variable "subnet_ids_asg" {
  description = "List private-subnets"       
  type        = list(string)
}

## ----- 
variable "eks_policy_vault_arn" {
  description = "Policy Vault" 
  type = string
}

variable "ssm_instance_policy" {
  type        = string
  description = "Policy of ssm instance"
}
variable "vaultUnsealKMSPolicy" {
  type        = string
  description = "Policy of vaultUnsealKMS"
}

variable "karpenter_node_kms_decrypt_lzaz-ssm" {
  description = "Policy karpenter_node_kms_decrypt_lzaz-ssm" 
  type = string
}

##------ networking
variable "subnet_ids" {
  type = set(string)
}

variable "private_subnets" {
  type = set(string)
}

variable "public_subnets" {
  type = set(string)
}

##------ node group variables
variable "ng_ndoes_desired_size" {
  type    = number
  default = 2
}

variable "ng_ndoes_max_size" {
  type    = number
  default = 3
}

variable "ng_ndoes_min_size" {
  type    = number
  default = 2
}
#eks_node_storage
variable "eks_node_storage" {
  type    = number
#  default = 20
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.meduim"]
  description = "node group list of instances types to choose from"
}


##------ kubernetes specific
variable "namespaces" {
  type        = set(string)
  description = "A set of required namespaces to be created in order to deploy our resources on them"
}


##---- karpenter specific
variable "instanceprofile_name" {
  description = "The name of the cluster"
  type        = string
}

variable "karpenter_namespace" {
  description = "The K8S namespace to deploy Karpenter into"
  # default     = "cluster-bootstrapping"
  type = string
}

variable "karpenter_version" {
  description = "Karpenter Version"
  default     = "v0.35.0"
  type        = string
}

variable "karpenter_target_nodegroup" {
  description = "The node group to deploy Karpenter to"
  type        = string
}

variable "bottlerocket_k8s_version" {
  description = "Kubernetes version for Bottlerocket AMI"
  default     = "1.30"
  type        = string
}



variable "s3_bucket_name" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}
