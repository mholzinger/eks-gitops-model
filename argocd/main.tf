module "argocd" {
  source      = "../shared/argocd"
  cluster_name = var.cluster_name
  kubeconfig   = var.kubeconfig
}

output "argocd_server_url" {
  value = module.argocd.server_url
}

output "argocd_auth_token" {
  value     = module.argocd.auth_token
  sensitive = true
}