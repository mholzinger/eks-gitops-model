# Create an EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws" # Use the shared EKS module
  version = "20.34.0"               # Use version 20.34.0 of the EKS module

  cluster_name    = local.cluster_name # Use the unique cluster name defined in locals
  cluster_version = "1.31"             # Kubernetes version for the EKS cluster

  # Enable public access to the EKS cluster endpoint
  cluster_endpoint_public_access = true

  # Grant admin permissions to the IAM entity creating the cluster
  enable_cluster_creator_admin_permissions = true

  # Use the VPC and subnets created by the VPC module
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Default settings for EKS-managed node groups
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64" # Use Amazon Linux 2 AMI for x86-based instances
  }

  # Define an EKS-managed node group with burstable instances
  eks_managed_node_groups = {
    burstable = {
      name = "burstable-nodes" # Name of the node group

      instance_types = ["t3.small"] # Use t3.small burstable instances
      capacity_type  = "ON_DEMAND"  # Use on-demand instances for simplicity

      # Define the minimum, maximum, and desired number of nodes
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}
