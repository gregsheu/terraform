resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  #data = {
    #"aws-auth.yml" = "${file("${path.module}/aws-auth.yaml")}"
  #}

  data = {
    mapRoles = <<YAML
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.id}:role/${data.aws_iam_role.eksworker.name}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.id}:role/${data.aws_iam_role.asg.name}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
  }
  lifecycle {
    ignore_changes = []
    prevent_destroy = true
  }
}
