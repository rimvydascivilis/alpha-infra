terraform {
  source = "../../../modules/k8s-addons"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl")).locals
  env         = local.common_vars.env
}

inputs = {
  env                 = local.env
  eks_name            = dependency.eks.outputs.cluster_name
  openid_provider_arn = dependency.eks.outputs.oidc_provider_arn

  enable_cluster_autoscaler       = true
  cluster_autoscaler_helm_version = "9.29.3"

  enable_load_balancer_controller       = true
  load_balancer_controller_helm_version = "1.6.1"
  load_balancer_controller_image_tag    = "v2.6.1"

  enable_argocd = true
  argocd_apps = []
  enable_argocd_ingress = true
  argocd_ingress_host   = "argocd.${local.env}.example.com"
  argocd_ingress_path   = "/"
  argocd_helm_version   = "5.46.7"
  argocd_image_tag      = "v2.8.4"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name      = "cluster"
    oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider"
  }
}

generate "helm_provider" {
  path      = "helm-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

data "aws_eks_cluster" "eks" {
    name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
    name = var.eks_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
      command     = "aws"
    }
  }
}
EOF
}

generate "kubernetes_provider" {
  path      = "kubernetes-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
    command     = "aws"
  }
}
EOF
}