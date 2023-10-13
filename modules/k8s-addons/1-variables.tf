variable "env" {
  description = "Environment name."
  type        = string
}

variable "eks_name" {
  description = "Name of the cluster."
  type        = string
}

variable "enable_cluster_autoscaler" {
  description = "Determines whether to deploy cluster autoscaler"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_helm_version" {
  description = "Cluster Autoscaler Helm verion"
  type        = string
}

variable "openid_provider_arn" {
  description = "IAM Openid Connect Provider ARN"
  type        = string
}

variable "enable_load_balancer_controller" {
  description = "Determines whether to deploy load balancer controller"
  type        = bool
  default     = false
}

variable "load_balancer_controller_helm_version" {
  description = "Load Balancer Controller Helm verion"
  type        = string
}

variable "load_balancer_controller_image_tag" {
  description = "Load Balancer Controller image tag"
  type        = string
}

variable "enable_argocd" {
  description = "Determines whether to deploy ArgoCD"
  type        = bool
  default     = false
}

variable "enable_argocd_ingress" {
  description = "Determines whether to deploy ArgoCD ingress"
  type        = bool
  default     = false
}

variable "argocd_ingress_host" {
  description = "ArgoCD ingress host"
  type        = string
}

variable "argocd_ingress_path" {
  description = "ArgoCD ingress path"
  type        = string
}

variable "argocd_helm_version" {
  description = "ArgoCD Helm verion"
  type        = string
}

variable "argocd_image_tag" {
  description = "ArgoCD image tag"
  type        = string
}

variable "argocd_apps" {
  description = "ArgoCD apps"
  type = list(object({
    name               = string
    project            = string
    repo_url           = string
    target_revision    = string
    path               = string
    destination_server = string
  }))
}

variable "enable_argocd_image_updater" {
  description = "Determines whether to deploy ArgoCD image updater"
  type        = bool
  default     = false
}

variable "argocd_image_updater_config" {
  description = "ArgoCD image updater config"
  type = object({
    helm_version = string
    image_tag    = string
    ecr          = any
  })
}

variable "enable_sealed_secrets" {
  description = "Determines whether to deploy Sealed Secrets"
  type        = bool
  default     = false
}

variable "sealed_secrets_helm_version" {
  description = "Sealed Secrets Helm verion"
  type        = string
}