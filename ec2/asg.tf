resource "aws_autoscaling_group" "this" {
  name                      = local.resource_context.asg.name
  max_size                  = local.resource_context.asg.max_size
  min_size                  = local.resource_context.asg.min_size
  force_delete              = local.resource_context.asg.force_delete
  desired_capacity          = local.resource_context.asg.desired_capacity
  health_check_type         = local.resource_context.asg.health_check_type
  health_check_grace_period = local.resource_context.asg.health_check_grace_period

  target_group_arns   = [aws_lb_target_group.this.arn]
  vpc_zone_identifier = local.resource_context.asg.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.this.id
    version = local.resource_context.asg.launch_template.version
  }

  tag {
    key                 = "Name"
    value               = local.resource_context.asg.name
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb_target_group.this,
    aws_launch_template.this
  ]
}