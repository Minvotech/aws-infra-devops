module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = "vpc_prod"
  cidr = "172.16.0.0/16"

  azs             = ["ca-central-1a", "ca-central-1b"]
  private_subnets = ["172.16.0.0/21", "172.16.8.0/21"]
  public_subnets  = ["172.16.168.0/22", "172.16.172.0/22"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "prod",
  }

  public_subnet_tags = {

    "Environment"                   = "prod"
    "Name"                           = "prod-base-networkPublicAZ1"
    "karpenter.sh/discovery"       = "eks-prod"
    "kubernetes.io/cluster/eks-prod" = "shared"
    "kubernetes.io/role/elb"       = "1"
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
  }

  private_subnet_tags = {
    Environment                       = "prod"
    Name                              = "prod-base-networkPrivateAZ2"
    ServiceProvider                   = "owais"
    "karpenter.sh/discovery"          = "eks-prod"
    "kubernetes.io/cluster/eks-prod"    = "shared"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    network                           = "private"

  }
}