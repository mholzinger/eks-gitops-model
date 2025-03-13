terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "~> 6.0" # Use the latest version available
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "argocd" {
  server_addr = "argocd-server.argocd.svc.cluster.local:443" # Example
  auth_token  = var.argocd_auth_token                        # Use a variable or hardcode if necessary
  insecure    = true                                         # Set to true if using self-signed certificates
}


# Configure the AWS provider to interact with AWS services.
# The region is specified by the `aws_region` variable.
#provider "aws" {
#  region = var.aws_region
#}

# Configure the Helm provider to deploy Helm charts to the Kubernetes cluster.
# The provider uses the kubeconfig file located at `~/.kube/config` to authenticate with the cluster.
#provider "helm" {
#  kubernetes {
#    config_path = "~/.kube/config"
#  }
#}

#provider "argocd" {
# Configuration for the ArgoCD provider
# You may need to provide additional details like the ArgoCD server URL and credentials
#  server_addr = "argocd-server.argocd.svc.cluster.local:443" # Example
#  auth_token  = var.argocd_auth_token # Use a variable or hardcode if necessary
#  insecure    = true # Set to true if using self-signed certificates
#}


