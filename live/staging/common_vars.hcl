locals {
  env = regex(".*/(.*)", get_terragrunt_dir())[0]

  common_tags = {
    "Environment" = local.env
    "Terraform"   = "true"
  }
}