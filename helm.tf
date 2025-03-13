# Deploy ArgoCD using the Helm chart from the official ArgoCD Helm repository.
# ArgoCD is a GitOps tool that automates the deployment of applications to Kubernetes.
resource "helm_release" "argocd" {
  name             = "argocd"                               # Name of the Helm release
  repository       = "https://argoproj.github.io/argo-helm" # URL of the Helm repository
  chart            = "argo-cd"                              # Name of the Helm chart
  version          = "5.0.0"                                # Version of the Helm chart to deploy
  namespace        = "argocd"                               # Kubernetes namespace where ArgoCD will be installed
  create_namespace = true                                   # Create the namespace if it does not exist

  # Configure the ArgoCD server service to use ClusterIP.
  # This ensures the service is only accessible within the cluster.
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
}
