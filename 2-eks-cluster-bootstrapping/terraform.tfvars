region = "ca-central-1"
namespace = "cluster-bootstrapping" #"cluster-bootstrapping"
cluster_name = "eks-prod"
cluster_id = "eks-prod"
namespace_kube-system = "kube-system"
namespace_apps-dev = "apps-dev"
namespace_apps-sta = "apps-sta"
namespace_apps-prod = "apps-prod"
namespace_cluster-bootstrapping = "cluster-bootstrapping"
namespace_argocd= "argocd"
namespace_monitoring= "monitoring"
namespace_logging= "logging"
namespace_vault= "vault"
namespace_vault-operator= "vault-secret-operator"
ssm_instance_policy = "arn:aws:iam::211337202074:policy/SSMInstance"
vaultUnsealKMSPolicy = "arn:aws:iam::211337202074:policy/vaultAutoUnsealKMS"
loki_buckets = ["owais-eks-prod-loki-chunks-prod", "owais-eks-prod-loki-ruler-prod", "owais-eks-prod-loki-admin-prod"]
kongappsec-namespace = "kong-appsec"