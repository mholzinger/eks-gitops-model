module "microservice" {
  source      = "../shared/argocd-app"
  app_name    = "microservice"
  repo_url    = "https://github.com/your-repo/microservice.git"
  target_revision = "main"
  path        = "manifests"
  namespace   = "default"
}

output "app_url" {
  value = module.microservice.app_url
}