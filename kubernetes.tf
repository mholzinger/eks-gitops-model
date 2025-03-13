resource "kubernetes_namespace" "microservice" {
  metadata {
    name = "microservice"
  }
}