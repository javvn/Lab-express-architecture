output "remote_state" {
  value = {
    context         = local.remote_context
    vpc             = local.vpc_context
    subnet_groups   = local.subnet_groups_context
    security_groups = local.security_groups_context
  }
}

output "ec2_instances" {
  value = { for root_k, root_v in module.ec2 : root_k => { for child_k, child_v in root_v : child_k => child_v if contains(local.output_search_set.ec2, child_k) } }
}

output "alb" {
  value = {
    alb      = { for k, v in aws_alb.this : k => v if contains(local.output_search_set.alb, k) }
    tg       = { for k, v in aws_lb_target_group.this : k => v if contains(local.output_search_set.alb_tg, k) }
    listener = { for k, v in aws_lb_listener.this : k => v if contains(local.output_search_set.alb_listener, k) }
  }
}

output "asg" {
  value = { for k, v in aws_autoscaling_group.this : k => v if contains(local.output_search_set.asg, k) }
}