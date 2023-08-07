output "aws_availability_zones_id" {
  value = data.aws_availability_zones.default.id
}

output "aws_availability_zones_name" {
  value = data.aws_availability_zones.default.names
}

output "aws_availzones" {
  value = data.aws_availability_zones.default.zone_ids
}

output "aws_ami" {
  value = data.aws_ami.eks.image_id
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "kubernetes_config_map" "aws-auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
}
