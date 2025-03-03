provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "eks-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
}


module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  cluster_name      = "eks-gitops-cluster"
  cluster_version   = "1.30"  # or 1.30, 1.31, 1.32, etc.
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnets
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}
