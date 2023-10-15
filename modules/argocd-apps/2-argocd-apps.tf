resource "kubernetes_manifest" "argocd_apps" {
  count = length(var.argocd_apps)
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name        = var.argocd_apps[count.index].name
      namespace   = "argocd"
      annotations = var.argocd_apps[count.index].annotations
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