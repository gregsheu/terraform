#For EKS
resource "aws_iam_role" "ekslb" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = ["sts.amazonaws.com"]
          }
        }
      }
    ]
  })
  name = "${terraform.workspace}-eksloadbalancercontroller"
}

resource "aws_iam_policy" "ekslb" {
  name = "${terraform.workspace}-eksloadbalancercontroller-policy"
  description = "EKS Load Balancer Policy"
  path = "/"
  policy = file("eksloadbalancercontroller.json")
  #policy = file("iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "ekslb" {
  role = aws_iam_role.ekslb.name
  policy_arn = aws_iam_policy.ekslb.arn
}

resource "aws_iam_role" "ekscluster" {
  name = "${terraform.workspace}-eksclusterrole"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "EKSClusterRole"
  }
}

resource "aws_iam_role" "eksworkernode" {
  name = "${terraform.workspace}-eksworkernoderole"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "EKSWorkerNodeRole"
  }
}

resource "aws_iam_role" "asg" {
  name = "${terraform.workspace}-eksselfmanagednode"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "AutoscalingEKSNode"
  }
}

resource "aws_iam_instance_profile" "asg" {
  name = "${terraform.workspace}-eksselfmanagednode"
  role = aws_iam_role.asg.name
}
