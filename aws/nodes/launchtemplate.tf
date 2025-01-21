resource "aws_launch_template" "asg" {
  #count = length(local.az_names)
  name = "${terraform.workspace}-${var.clustername}-launchtemplate"
  #name = "${terraform.workspace}-${var.clustername}-${local.az_names[count.index]}"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
    }
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  credit_specification {
    cpu_credits = "standard"
  }
  disable_api_termination = true
  ebs_optimized = true
  image_id = data.aws_ami.eks.image_id
  #instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    name = data.aws_iam_role.asg.name
  }
  instance_type = "t3.medium"
  key_name = var.keypair
  monitoring {
    enabled = true
  }
  network_interfaces {
    #associate_public_ip_address = true
    #security_groups = [data.aws_security_groups.private.ids[0], data.aws_security_groups.default.ids[0]]
    security_groups = [data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
    #subnet_id = data.aws_subnets.default.ids[1]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      #Name = local.az_names[count.index]
      Name = "${terraform.workspace}-${var.clustername}-launchtemplate"
      key = "kubernetes.io/cluster/${terraform.workspace}-${var.clustername}"
      value = "owned"
      propagate_at_launch = true
    }
  }
  #user_data = filebase64("${path.module}/userdata.txt")
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { cluster = "${terraform.workspace}-${var.clustername}" }))
  update_default_version = false
}
