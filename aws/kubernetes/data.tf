locals {
  #az_names = data.aws_availability_zones.default.zone_ids
  az_names = contains(data.aws_availability_zones.default.zone_ids, "use1-az3") ? setsubtract(data.aws_availability_zones.default.zone_ids, ["use1-az3"]) : data.aws_availability_zones.default.zone_ids
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_eks_cluster" "eks" {
  name = "${terraform.workspace}-${var.clustername}"
}

data "aws_eks_cluster_auth" "auth" {
  name = "${terraform.workspace}-${var.clustername}"
}

data "aws_ami" "eks" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "owner-alias"
    values =["amazon"]
  }
  filter {
    name = "name"
    values =["*amazon-eks-node-1.25*"]
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

data "aws_iam_role" "ekscluster" {
  name = "${terraform.workspace}-eksclusterrole"
}

data "aws_iam_role" "eksworker" {
  name = "${terraform.workspace}-eksworkernoderole"
}

data "aws_iam_role" "asg" {
  name = "${terraform.workspace}-eksselfmanagednode"
}

data "aws_iam_role" "ekslb" {
  name = "${terraform.workspace}-eksloadbalancercontroller"
}

data "aws_vpc" "default" {
  #filter {
  #  name = "vpc-id"
  #  values = ["${var.vpc}"]
  #}
  tags = {
    Name= "${terraform.workspace}-vpc"
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

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

#data "aws_subnet" "public_subnetc" {
#  filter {
#    name   = "vpc-id"
#    values = [data.aws_vpc.default.id]
#  }
#  filter {
#    name   = "tag:Name"
#    values = ["${terraform.workspace}-publicsubnetc"]
#  }
#}
#
#data "aws_subnet" "private_subneta" {
#  filter {
#    name   = "vpc-id"
#    values = [data.aws_vpc.default.id]
#  }
#  filter {
#    name   = "tag:Name"
#    values = ["${terraform.workspace}-privatesubneta"]
#  }
#}
#
#data "aws_subnet" "private_subnetb" {
#  filter {
#    name   = "vpc-id"
#    values = [data.aws_vpc.default.id]
#  }
#  filter {
#    name   = "tag:Name"
#    values = ["${terraform.workspace}-privatesubnetb"]
#  }
#}
#
#data "aws_subnet" "private_subnetc" {
#  filter {
#    name   = "vpc-id"
#    values = [data.aws_vpc.default.id]
#  }
#  filter {
#    name   = "tag:Name"
#    values = ["${terraform.workspace}-privatesubnetc"]
#  }
#}

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

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

data "kubernetes_config_map" "aws-auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
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
