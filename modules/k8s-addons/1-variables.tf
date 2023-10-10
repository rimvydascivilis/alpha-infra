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