resource "aws_autoscaling_group" "this" {
  name                      = local.resource_context.auto_scaling.name
  max_size                  = local.resource_context.auto_scaling.max_size
  min_size                  = local.resource_context.auto_scaling.min_size
  force_delete              = local.resource_context.auto_scaling.force_delete
  desired_capacity          = local.resource_context.auto_scaling.desired_capacity
  health_check_type         = local.resource_context.auto_scaling.health_check_type
  health_check_grace_period = local.resource_context.auto_scaling.health_check_grace_period

  target_group_arns   = [aws_lb_target_group.this.arn]
  vpc_zone_identifier = local.resource_context.auto_scaling.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.this.id
    version = local.resource_context.auto_scaling.launch_template.version
  }

  tag {
    key                 = "Name"
    value               = "${local.resource_context.auto_scaling.name}-propagate"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb_target_group.this,
    aws_launch_template.this
  ]
}