resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_helm_version

  set {
    name  = "global.image.tag"
    value = var.argocd_image_tag
  }

  set {
    name  = "server.ingress.enabled"
    value = var.enable_argocd_ingress
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = var.argocd_ingress_host
  }

  set {
    name  = "server.ingress.paths[0]"
    value = var.argocd_ingress_path
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internet-facing"
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
    value = "default"
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.order"
    value = "1"
  }

  set {
    name  = "server.service.type"
    value = "NodePort"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
}