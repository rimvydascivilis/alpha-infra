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

  dynamic "set" {
    for_each = var.enable_argocd_ingress ? [
      {
        name  = "server.ingress.hosts[0]"
        value = var.argocd_ingress_host
      },
      {
        name  = "server.ingress.paths[0]"
        value = var.argocd_ingress_path
      },
      {
        name  = "server.ingress.ingressClassName"
        value = "alb"
      },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
        value = "internet-facing"
      },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
        value = "default"
      },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.order"
        value = "1"
      }
    ] : []

    content {
      name  = set.value.name
      value = set.value.value
    }
  }
  set {
    name  = "server.service.type"
    value = var.enable_argocd_ingress ? "NodePort" : "ClusterIP"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}

resource "kubernetes_manifest" "argocd_apps" {
  count = var.enable_argocd ? length(var.argocd_apps) : 0
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.argocd_apps[count.index].name
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = var.argocd_apps[count.index].project
      source = {
        repoURL        = var.argocd_apps[count.index].repo_url
        targetRevision = var.argocd_apps[count.index].target_revision
        path           = var.argocd_apps[count.index].path
      }
      destination = {
        server = var.argocd_apps[count.index].destination_server
      }
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = true
        }
        syncOptions = [
          "Validate=true",
          "CreateNamespace=true",
          "PrunePropagationPolicy=Foreground",
          "PruneLast=true",
        ]
      }
    }
  }
}