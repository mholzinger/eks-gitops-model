provider "argocd" {
  server_addr = "argocd-server.argocd.svc.cluster.local:443"
  auth_token  = var.argocd_auth_token
  insecure    = true
}