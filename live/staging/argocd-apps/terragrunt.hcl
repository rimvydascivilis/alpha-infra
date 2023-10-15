terraform {
  source = "../../../modules/argocd-apps"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl")).locals
  env         = local.common_vars.env
}

inputs = {
  eks_name = dependency.k8s-addons.outputs.eks_name
  argocd_apps = [

  ]
}

dependency "k8s-addons" {
  config_path = "../k8s-addons"

  mock_outputs = {
    eks_name = "cluster-name"
  }
}

generate "kubernetes_provider" {
  path      = "kubernetes-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "eks" {
    name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
    name = var.eks_name
}

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