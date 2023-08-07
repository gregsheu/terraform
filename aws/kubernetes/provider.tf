#If there are vpc endpoints, add permissions for aws managed workernodes or will fail to join.
provider "aws" {
  region = "us-east-2"
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.eksauth.token
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eksauth.token
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = ["eks", "get-token", "--cluster-name", "data.aws_eks_cluster.cluster.name"]
      command = "aws"
    }
  }
}
