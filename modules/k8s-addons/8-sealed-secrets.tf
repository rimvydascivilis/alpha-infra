resource "helm_release" "sealed_secrets" {
  count = var.enable_sealed_secrets ? 1 : 0

  name = "sealed-secrets"

  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "sealed-secrets"
  namespace        = "kube-system"
  create_namespace = true
  version          = var.sealed_secrets_helm_version
}