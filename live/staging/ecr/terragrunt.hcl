terraform {
  source = "tfr:///terraform-aws-modules/ecr/aws?version=1.6.0"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl")).locals
  env         = local.common_vars.env
  common_tags = local.common_vars.common_tags
}

inputs = {
  repository_name = "app-${local.env}"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 15 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 15
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.common_tags
}