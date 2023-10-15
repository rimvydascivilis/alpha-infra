data "aws_iam_openid_connect_provider" "this" {
  arn = var.openid_provider_arn
}