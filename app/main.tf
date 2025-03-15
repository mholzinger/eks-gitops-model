provider "argocd" {
  server_addr = "argocd-server.argocd.svc.cluster.local:443"
  auth_token  = var.argocd_auth_token
  insecure    = true
}

resource "argocd_application" "microservice" {
  metadata {
    name      = "microservice-app"
    namespace = "argocd"
  }
  spec {
    project = "default"
    source {
      repo_url        = "https://github.com/your-repo/microservice.git"
      path            = "manifests"
      target_revision = "main"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
    }
    sync_policy {
      automated {
        prune    = true
        self_heal = true
      }
    }
  }
}
