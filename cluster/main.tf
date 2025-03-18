locals {
  cluster_name = "eks-gitops-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
#  source  = "terraform-aws-modules/vpc/aws"
#  version = "5.19.9"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=961c9b51e3ed3959d9419f019e7085c087bf7297"  # commit hash of version 5.19.0

  name = "eks-gitops-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "eks" {
  #source  = "terraform-aws-modules/eks/aws"
  #version = "20.34.0"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=dd2089b73b4ff296e519830efdfda760e8d52b8a" # commit hash of version 20.34.0

  cluster_name    = local.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    burstable = {
      name           = "burstable-nodes"
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}

resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}
    EOT
  }
}
