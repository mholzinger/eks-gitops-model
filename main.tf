provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-gitops-cluster"
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets

  node_groups = {
    default = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "eks-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
