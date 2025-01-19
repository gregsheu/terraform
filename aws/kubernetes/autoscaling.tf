#resource "aws_autoscaling_group" "asg" {
#  #count = length(local.az_names)
#  name = "${terraform.workspace}-${var.clustername}"
#  #availability_zones = [data.aws_availability_zones.default.names[0]]
#  #availability_zones = slice(local.az_names, 0, length(local.az_names))
#  vpc_zone_identifier = slice(data.aws_subnets.default.ids, 0, length(local.az_names))
#  desired_capacity    = 1
#  max_size            = 2
#  min_size            = 1
#  launch_template {
#    id      = aws_launch_template.asg.id
#    version = "$Latest"
#  }
#  tag {
#    key                 = "Name"
#    value               = "${var.clustername}-asg"
#    propagate_at_launch = true
#  }
#  tag {
#    key                 = "kubernetes.io/cluster/${var.clustername}"
#    value               = "owned"
#    propagate_at_launch = true
#  }
#  tag {
#    key                 = "eks:nodegroup-name"
#    value               = "${var.clustername}-asg"
#    propagate_at_launch = true
#  }
#}
