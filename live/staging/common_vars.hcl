locals {
  // TODO: Create regex to get env from module path (e.g. "dev", "staging", "prod")
  env = "dev"

  common_tags = {
    "Environment" = local.env
    "Terraform"   = "true"
  }
}