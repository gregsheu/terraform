output "subnets" {
  value = data.aws_subnets.default
}

output "eks_identity" {
  value = aws_eks_cluster.cluster.identity[0]
}
