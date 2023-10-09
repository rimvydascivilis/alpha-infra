terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.2"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "data" {
  config_path = "../data"

  mock_outputs = {
    first_3_azs = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
    ]
  }
}

locals {
  common_vars    = read_terragrunt_config(find_in_parent_folders("common_vars.hcl")).locals
  env            = local.common_vars.env
  common_tags    = local.common_vars.common_tags
  vpc_cidr_block = "10.0.0.0/16"
  vpc_name       = "vpc-${local.env}"
}

inputs = {
  name            = local.vpc_name
  azs             = dependency.data.outputs.first_3_azs
  private_subnets = [for k, v in dependency.data.outputs.first_3_azs : cidrsubnet(local.vpc_cidr_block, 8, k)]
  public_subnets  = [for k, v in dependency.data.outputs.first_3_azs : cidrsubnet(local.vpc_cidr_block, 8, k + length(dependency.data.outputs.first_3_azs))]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"    = 1
    "kubernetes.io/cluster/${local.env}" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"             = 1
    "kubernetes.io/cluster/${local.env}" = "owned"
  }

  tags = local.common_tags
}