resource "aws_launch_template" "launch_tpl" {
  name          = "${var.module_prefix}-tpl"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  user_data     = var.user_data

  iam_instance_profile {
    arn = var.instance_profile_arn
  }

  vpc_security_group_ids = [var.sg_id]
  tags = {
    Name = "${var.module_prefix}-launch-tpl"
  }
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template

resource "aws_autoscaling_group" "this" {
  name                      = "${var.module_prefix}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_cap
  health_check_grace_period = 120 # seconds = 2 minutes
  health_check_type         = var.asg_health_check_type
  vpc_zone_identifier       = [var.sub_a_id, var.sub_b_id]
  target_group_arns         = [var.tg_arn]

  launch_template {
    id      = aws_launch_template.launch_tpl.id
    version = aws_launch_template.launch_tpl.latest_version
  }
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.module_prefix}-cpu-target"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target
  }
}
