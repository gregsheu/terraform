resource "helm_release" "ekslb" {
  name = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts/"
  chart = "aws-load-balancer-controller"
  version = "1.8"

  set {
    name  = "clusterName"
    value = "${terraform.workspace}-${var.clustername}"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  # eks 1.30
  set {
    name  = "vpcId"
    value = data.aws_vpc.default.id
  }

  # eks 1.30
  set {
    name  = "aws-region"
    value = data.aws_region.current.name
  }
}
