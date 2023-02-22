resource "aws_alb" "this" {
  name                       = local.resource_context.alb.name
  internal                   = local.resource_context.alb.internal
  subnets                    = local.resource_context.alb.subnets
  ip_address_type            = local.resource_context.alb.ip_address_type
  security_groups            = local.resource_context.alb.security_groups
  load_balancer_type         = local.resource_context.alb.load_balancer_type
  enable_deletion_protection = local.resource_context.alb.enable_deletion_protection
  tags                       = merge(local.common_tags, { Name = local.resource_context.alb.name })

  access_logs {
    bucket  = local.resource_context.alb.access_logs.bucket
    prefix  = local.resource_context.alb.access_logs.prefix
    enabled = local.resource_context.alb.access_logs.enabled
  }

  depends_on = [aws_launch_template.this]
}

resource "aws_lb_target_group" "this" {
  name                          = local.resource_context.alb_tg.name
  port                          = local.resource_context.alb_tg.port
  protocol                      = local.resource_context.alb_tg.protocol
  protocol_version              = local.resource_context.alb_tg.protocol_version
  vpc_id                        = local.resource_context.alb_tg.vpc_id
  target_type                   = local.resource_context.alb_tg.target_type
  load_balancing_algorithm_type = local.resource_context.alb_tg.load_balancing_algorithm_type
  tags                          = merge(local.common_tags, { Name = local.resource_context.alb_tg.name })

  depends_on = [aws_alb.this]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = local.resource_context.alb_listener.port
  protocol          = local.resource_context.alb_listener.protocol
  ssl_policy        = local.resource_context.alb_listener.ssl_policy
  tags              = merge(local.common_tags, { Name = local.resource_context.alb_listener.name })

  default_action {
    type             = local.resource_context.alb_listener.default_action.type
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [aws_alb.this, aws_lb_target_group.this]
}