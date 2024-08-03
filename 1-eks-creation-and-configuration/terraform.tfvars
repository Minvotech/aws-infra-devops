# general
region = "ca-central-1"
# just use it for local testing switched when its in github actions to a role
aws_profile = "default"


s3_bucket_name      = "owais-tfstate-prod"
dynamodb_table_name = "owais-tfstate-locking-prod"



# cluster specific
cluster_name = "eks-prod"


## networking
subnet_ids = ["subnet-07e30e8b543d0c68b", "subnet-020ce2451adfa4b35", "subnet-0aea10e7b443ad009", "subnet-0d99526c6c3d602a1"]
subnet_ids_asg = ["subnet-07e30e8b543d0c68b", "subnet-020ce2451adfa4b35"]
public_subnets = ["subnet-0d99526c6c3d602a1",  "subnet-0aea10e7b443ad009"]
private_subnets = ["subnet-07e30e8b543d0c68b", "subnet-020ce2451adfa4b35"]

# Policy ARN Vault :
eks_policy_vault_arn = "arn:aws:iam::211337202074:policy/vaultAutoUnsealKMS"

ssm_instance_policy = "arn:aws:iam::211337202074:policy/SSMInstance"
vaultUnsealKMSPolicy = "arn:aws:iam::211337202074:policy/vaultAutoUnsealKMS"
karpenter_node_kms_decrypt_lzaz-ssm = "arn:aws:iam::211337202074:policy/karpenter_node_kms_decrypt_owais-ssm"


#-- versions :
kubernetes_version = "1.30" #"1.28"
ebs_csi_driver_version = "v1.31.0"
ami_type = "AL2_x86_64"

## node_group 
ng_ndoes_desired_size = 3
ng_ndoes_max_size     = 3
ng_ndoes_min_size     = 3
instance_types        = ["t3.medium"]
eks_node_storage   = 35


## kubernetes specific
namespaces = ["cluster-bootstrapping", "monitoring", "apps-prod", "karpenter", "argocd", "elk", "logging", "nginx"]


##------ karpenter specific
karpenter_target_nodegroup = "ng-managed-workers-spot"
instanceprofile_name       = "eksProd2"
karpenter_namespace        = "karpenter"
karpenter_version          = "v0.32.3" #"v0.32.3" #"v0.31.2" #"v0.27.0"
  
