variable "eks_name" {
  description = "EKS cluster name"
  type        = string
}

variable "argocd_apps" {
  description = "ArgoCD apps"
  type = list(object({
    name               = string
    annotations        = map(string)
    project            = string
    repo_url           = string
    target_revision    = string
    path               = string
    destination_server = string
  }))
}