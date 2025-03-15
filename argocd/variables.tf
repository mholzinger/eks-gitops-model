variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubeconfig" {
  description = "Kubeconfig file for the EKS cluster"
  type        = string
}