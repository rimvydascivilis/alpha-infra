data "aws_iam_policy_document" "argocd_image_updater" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:argocd-image-updater"]
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "argocd_image_updater" {
  count = var.enable_argocd_image_updater ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.argocd_image_updater.json
  name               = "${var.eks_name}-argocd-image-updater"
}

resource "aws_iam_policy" "argocd_image_updater" {
  count = var.enable_argocd_image_updater ? 1 : 0

  policy = file("${path.module}/policies/argocd-image-updater.json")
  name   = "${var.eks_name}-argocd-image-updater"
}

resource "aws_iam_role_policy_attachment" "argocd_image_updater" {
  count = var.enable_argocd_image_updater ? 1 : 0

  role       = aws_iam_role.argocd_image_updater[0].name
  policy_arn = aws_iam_policy.argocd_image_updater[0].arn
}

resource "helm_release" "argocd_image_updater" {
  count = var.enable_argocd_image_updater ? 1 : 0

  name = "argocd-image-updater"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_image_updater_config.helm_version

  values = [templatefile("${path.module}/templates/argocd-image-updater-values.yml.tftpl", {
    image_tag                = var.argocd_image_updater_config.image_tag
    ecr                      = var.argocd_image_updater_config.ecr
    service_account_role_arn = var.enable_argocd_image_updater ? aws_iam_role.argocd_image_updater[0].arn : null
  })]
}