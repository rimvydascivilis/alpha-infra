data "aws_iam_policy_document" "aws_load_balancer_controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  count = var.enable_load_balancer_controller ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller.json
  name               = "${var.eks_name}-load-balancer-controller"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  count = var.enable_load_balancer_controller ? 1 : 0

  policy = file("${path.module}/policies/load-balancer-controller.json")
  name   = "${var.eks_name}-load-balancer-controller"
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  count = var.enable_load_balancer_controller ? 1 : 0

  role       = aws_iam_role.aws_load_balancer_controller[0].name
  policy_arn = aws_iam_policy.aws_load_balancer_controller[0].arn
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_load_balancer_controller ? 1 : 0

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.load_balancer_controller_helm_version

  set {
    name  = "clusterName"
    value = var.eks_name
  }

  set {
    name  = "image.tag"
    value = var.load_balancer_controller_image_tag
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller[0].arn
  }
}