resource "aws_eks_cluster" "cluster" {
  name = "${terraform.workspace}-${var.clustername}"
  role_arn = aws_iam_role.ekscluster.arn
  vpc_config {
    #subnet_ids = [data.aws_subnet.private_subneta.id, data.aws_subnet.private_subnetb.id]
    subnet_ids = slice(data.aws_subnets.default.ids, 0, length(local.az_names))
    security_group_ids = [data.aws_security_groups.private.ids[0], data.aws_security_groups.default.ids[0]]
  }
  #enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  version = var.eks_version
}

resource "aws_cloudwatch_log_group" "cluster" {
  name  = aws_eks_cluster.cluster.name
  retention_in_days = 7
}

resource "aws_eks_node_group" "eks" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "${terraform.workspace}-${var.clustername}-workernode"
  node_role_arn  = aws_iam_role.eksworkernode.arn
  #subnet_ids = [data.aws_subnet.private_subneta.id, data.aws_subnet.private_subnetb.id]
  subnet_ids = slice(data.aws_subnets.default.ids, 0, length(local.az_names))
  scaling_config {
    desired_size = var.num_node
    max_size = var.max_node
    min_size = var.min_node
  }
  remote_access {
    ec2_ssh_key = var.keypair
    source_security_group_ids = [data.aws_security_groups.private.ids[0], data.aws_security_groups.default.ids[0]]
  }
  update_config {
    max_unavailable = 2
  }
}
#aws eks 1.30 doesn't need to create oidc resources
resource "aws_eks_identity_provider_config" "eks" {
  count = var.eks_version == "1.27" ? 1 : 0
  cluster_name = aws_eks_cluster.cluster.name
  oidc {
    client_id = replace(replace(data.tls_certificate.eks.url, "https://", ""), "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/", "")
    identity_provider_config_name = "eksoidc"
    #issuer_url = aws_eks_cluster.cluster.identity[0]["oidc"][0]["issuer"]
    issuer_url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  }
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
  url = aws_eks_cluster.cluster.identity[0]["oidc"][0]["issuer"]
  #url = data.tls_certificate.eks.url
}

