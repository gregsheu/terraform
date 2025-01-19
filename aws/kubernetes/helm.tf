resource "local_file" "kubeconfig" {
  content  = <<EOL
apiVersion: v1
kind: Config
clusters:
- name: "aws"
  cluster:
    certificate-authority-data: "${base64encode(data.aws_eks_cluster.cluster.certificate_authority[0].data)}"
    server: "${data.aws_eks_cluster.cluster.endpoint}"
contexts:
- name: "aws-context"
  context:
    cluster: "aws"
    user: "aws-user"
current-context: "aws-context"
users:
- name: "aws-user"
  user:
    token: "${data.aws_eks_cluster_auth.eksauth.token}"
EOL
  filename = "${path.module}/kubeconfig"
}

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
