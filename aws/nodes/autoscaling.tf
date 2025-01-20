resource "aws_autoscaling_group" "asg" {
  #count = length(local.az_names)
  name = "${terraform.workspace}-${var.clustername}"
  #availability_zones = [data.aws_availability_zones.default.names[0]]
  #availability_zones = slice(local.az_names, 0, length(local.az_names))
  vpc_zone_identifier = slice(data.aws_subnets.default.ids, 0, length(local.az_names))
  desired_capacity    = 2 
  max_size            = 4 
  min_size            = 2 
  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-${var.clustername}-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${terraform.workspace}-${var.clustername}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "eks:nodegroup-name"
    value               = "${terraform.workspace}-${var.clustername}-asg"
    propagate_at_launch = true
  }
}
