terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      # https://registry.terraform.io/providers/argoproj-labs/argocd/latest
      version = "~> 6.0"
    }
  }
}

provider "argocd" {
  server_addr = "argocd-server.argocd.svc.cluster.local:443"
  auth_token  = var.argocd_auth_token
  insecure    = true
}
