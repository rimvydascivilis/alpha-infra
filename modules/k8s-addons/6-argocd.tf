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
    name  = "server.ingress.hosts"
    value = var.argocd_ingress_hosts
  }

  set {
    name  = "server.ingress.paths"
    value = var.argocd_ingress_paths
  }

  set {
    name = "server.ingress.annotations"
    value = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    }
  }

  set {
    name  = "server.service.type"
    value = "NodePort"
  }

  set {
    name  = "server.extraArgs"
    value = ["--insecure"]
  }
}