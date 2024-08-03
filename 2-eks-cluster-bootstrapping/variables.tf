variable "cluster_id" {
  description = "Name of the EKS cluster where the ingress nginx will be deployed"
  type        = string

  }
variable "namespace" {
  description = "Namespace to release argocd into"
  type        = string
  default     = "kubecost"
}


variable "region" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}
#namespace_kube-system
variable "namespace_kube-system" {
  description = "Namespace kube-system"
  type        = string
}

variable "namespace_apps-prod" {
  description = "Namespace  apps-prod"
  type        = string
}
variable "namespace_apps-dev" {
  description = "Namespace  apps-dev"
  type        = string
}
variable "namespace_apps-sta" {
  description = "Namespace apps-sta"
  type        = string
}
variable "namespace_cluster-bootstrapping" {
  description = "Namespace cluster-bootstrapping "
  type        = string
}

variable "namespace_monitoring" {
  description = "Namespace monitoring "
  type        = string
}

variable "namespace_logging" {
  description = "Namespace logging "
  type        = string
}
variable "namespace_argocd" {
  type = string
  default = "argocd"  
}
variable "namespace_vault" {
  description = "Namespace vault "
  type        = string
}
variable "namespace_vault-operator" {
  description = "Namespace vault-operator "
  type        = string
}

variable "ssm_instance_policy" {
  type        = string
  description = "Policy of ssm instance"
}
variable "vaultUnsealKMSPolicy" {
  type        = string
  description = "Policy of vaultUnsealKMS"
}

# loki buckets 
variable "loki_buckets" {
  type        = set(string)
  description = "A set of required buckets names for loki"
}

variable "kongappsec-namespace" {
  type = string
}