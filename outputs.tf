output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID associated with the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "The AWS region where the cluster is deployed"
  value       = var.aws_region
}

