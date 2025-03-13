resource "helm_release" "microservice" {
  name       = "microservice"
  repository = "https://charts.helm.sh/stable"
  chart      = "microservice"
  version    = "1.0.0"
  namespace  = kubernetes_namespace.microservice.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]
}
