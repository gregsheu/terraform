resource "kubernetes_service_account" "awslbcontroller" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/${data.aws_iam_role.ekslb.name}"
    }
  }
}
