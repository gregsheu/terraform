resource "local_file" "kubeconfig" { 
  content = templatefile("${path.module}/kubeconfig.tpl", { 
    arn = data.aws_eks_cluster.eks.arn
    endpoint = data.aws_eks_cluster.eks.endpoint 
    certificate_authority = data.aws_eks_cluster.eks.certificate_authority[0].data
    token = data.aws_eks_cluster_auth.auth.token 
    cluster_name = data.aws_eks_cluster.eks.name }) 
  filename = "${path.module}/kubeconfig.yaml" 
}

