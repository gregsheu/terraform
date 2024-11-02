resource "helm_release" "ekslb" {
  name = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts/"
  chart = "aws-load-balancer-controller"
  version = "1.8"

  set {
    name  = "clusterName"
    value = var.clustername
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
    value = "vpc-000cbcda306125207"
  }

  # eks 1.30
  set {
    name  = "aws-region"
    value = "us-east-2"
  }
  #depends_on = [null_resource.bootstrap]
}
