terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=19.17.1"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-1234567890"
    private_subnets = [
      "subnet-1234567890",
      "subnet-1234567891",
      "subnet-1234567892",
    ]
    intra_subnets = [
      "subnet-1234567893",
      "subnet-1234567894",
      "subnet-1234567895",
    ]
  }
}

locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common_vars.hcl")).locals
  env          = local.common_vars.env
  common_tags  = local.common_vars.common_tags
  cluster_name = "eks-${local.env}"
}

inputs = {
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.28"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    disk_size = 10
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 4

      instance_types = ["t4g.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = local.common_tags
}