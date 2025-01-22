locals {
  #az_names = data.aws_availability_zones.default.zone_ids
  az_names = contains(data.aws_availability_zones.default.zone_ids, "use1-az3") ? setsubtract(data.aws_availability_zones.default.zone_ids, ["use1-az3"]) : data.aws_availability_zones.default.zone_ids
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ami" "eks" {
  most_recent = true
  #owners = ["amazon"]
  filter {
    name = "owner-alias"
    values =["amazon"]
  }
  filter {
    name = "name"
    values =["*amazon-eks-node-${var.eks_version}*"]
  }
  filter {
    name = "is-public"
    values =["true"]
  }
  filter {
    name = "virtualization-type"
    values =["hvm"]
  }
  filter {
    name = "architecture"
    values =["x86_64"]
  }
}

#data "aws_iam_role" "ekscluster" {
#  name = "eksclusterrole"
#}
#
#data "aws_iam_role" "eksworker" {
#  name = "eksworkernoderole"
#}
#
#data "aws_iam_role" "asg" {
#  name = "eksselfmanagednode"
#}
#
data "aws_vpc" "default" {
  #filter {
  #  name = "vpc-id"
  #  values = ["${var.vpc}"]
  #}
  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}

data "aws_availability_zones" "default" {
  #all_availability_zones = true
  filter {
    name = "opt-in-status"
    #values = ["not-opted-in", "opted-in"]
    values = ["opt-in-not-required"]
  }
}

data "aws_security_groups" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${terraform.workspace}-defaultsg"]
  }
}

data "aws_security_groups" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${terraform.workspace}-privatesg"]
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_ami" "ecs" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "owner-alias"
    values =["amazon"]
  }
  filter {
    name = "name"
    values =["*ecs-hvm*"]
  }
  filter {
    name = "is-public"
    values =["true"]
  }
  filter {
    name = "virtualization-type"
    values =["hvm"]
  }
  filter {
    name = "architecture"
    values =["x86_64"]
  }
}

data "aws_iam_policy" "cloud_watch_log" {
  name = "CloudWatchLogsFullAccess"
}

data "aws_iam_policy" "ec2_ecs" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy" "ec2_ssm" {
  name = "AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "cloud_watch" {
  name = "CloudWatchFullAccess"
}

data "aws_iam_policy" "s3" {
  name = "AmazonS3FullAccess"
}

#data  "aws_ecr_repository" "ecr" {
#  name = "${terraform.workspace}"
#}
#
#data "aws_route53_zone" "staging-sandbox" {
#  name = "${var.dnsname}"
#}
#
#data "aws_acm_certificate" "staging-sandbox" {
#  domain = "*.${var.dnsname}"
#  types = ["AMAZON_ISSUED"]
#  most_recent = true
#}
#
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

#output "ecruri" {
#  value = data.aws_ecr_repository.ecr.repository_url
#}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

#data "aws_iam_policy_document" "eks" {
#  statement {
#    actions = ["sts:AssumeRoleWithWebIdentity"]
#    effect  = "Allow"
#
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#    }
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
#      values   = ["sts.amazonaws.com"]
#    }
#    principals {
#      identifiers = [aws_iam_openid_connect_provider.eks.arn]
#      type        = "Federated"
#    }
#  }
#}

