# Configure the AWS provider to interact with AWS services.
# The region is specified by the `aws_region` variable.
provider "aws" {
  region = var.aws_region
}

# Configure the Helm provider to deploy Helm charts to the Kubernetes cluster.
# The provider uses the kubeconfig file located at `~/.kube/config` to authenticate with the cluster.
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
