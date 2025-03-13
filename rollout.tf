resource "helm_release" "argo-rollouts" {
  name             = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  version          = "2.0.0"
  namespace        = "argo-rollouts"
  create_namespace = true
}
