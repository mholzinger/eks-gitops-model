# Configure the AWS provider
provider "aws" {
  region = var.aws_region # Use the AWS region specified in the `aws_region` variable
}

# Fetch available availability zones in the specified region
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status" # Filter for availability zones that do not require opt-in
    values = ["opt-in-not-required"]
  }
}

# Define local variables for reuse throughout the configuration
locals {
  cluster_name = "eks-gitops-${random_string.suffix.result}" # Generate a unique cluster name using a random suffix
}

# Generate a random string to ensure unique resource names
resource "random_string" "suffix" {
  length  = 8     # Length of the random string
  special = false # Do not include special characters
}

# Create a VPC for the EKS cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0" # Use version 5.19.0 of the VPC module

  name = "eks-gitops-vpc" # Name of the VPC
  cidr = "10.0.0.0/16"    # CIDR block for the VPC

  # Use the first 3 availability zones in the region
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Define private subnets for worker nodes
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Define public subnets for load balancers and public-facing resources
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  # Enable NAT gateway for outbound internet access from private subnets
  enable_nat_gateway = true
  single_nat_gateway = true # Use a single NAT gateway for cost savings

  # Enable DNS hostnames for the VPC
  enable_dns_hostnames = true

  # Tag public subnets for use with Kubernetes load balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  # Tag private subnets for use with Kubernetes internal load balancers
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Create an EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0" # Use version 20.34.0 of the EKS module

  cluster_name    = local.cluster_name # Use the unique cluster name defined in locals
  cluster_version = "1.29"             # Kubernetes version for the EKS cluster

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

# Fetch the IAM policy for the EBS CSI Driver
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create an IAM role for the EBS CSI Driver using IRSA (IAM Roles for Service Accounts)
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.53.0" # Use version 5.53.0 of the IAM module

  create_role = true                                               # Create a new IAM role
  role_name   = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}" # Unique role name based on the cluster name

  # Use the OIDC provider URL from the EKS cluster
  provider_url = module.eks.oidc_provider

  # Attach the EBS CSI Driver policy to the role
  role_policy_arns = [data.aws_iam_policy.ebs_csi_policy.arn]

  # Define the service account that will assume this role
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
