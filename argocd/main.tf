resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.0.0"
  namespace  = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
}

resource "null_resource" "retrieve_argocd_token" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = <<EOT
      kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > argocd_password.txt
      argocd login localhost:8080 --username admin --password $(cat argocd_password.txt) --insecure
      argocd account generate-token > argocd_token.txt
    EOT
  }
}

output "argocd_token" {
  value     = file("argocd_token.txt")
  sensitive = true
}
