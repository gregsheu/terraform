resource "helm_release" "ekslb" {
  name = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts/"
  chart = "aws-load-balancer-controller"

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
  #depends_on = [null_resource.bootstrap]
}
