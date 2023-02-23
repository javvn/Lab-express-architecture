locals {
  common_tags = data.terraform_remote_state.vpc.outputs.common_tags

  context                 = yamldecode(file(var.config_file)).context
  remote_context          = data.terraform_remote_state.vpc.outputs.context
  vpc_context             = data.terraform_remote_state.vpc.outputs.network.vpc
  subnet_groups_context   = data.terraform_remote_state.vpc.outputs.network.subnet_groups
  security_groups_context = data.terraform_remote_state.vpc.outputs.network.security_groups

  # EC2 public private division

  resource_context = {
    role = merge({ for k, v in yamldecode(templatefile(var.config_file, local.context)).role : k => v }, {
      assume_role_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "ec2.amazonaws.com"
            },
            "Action" : "sts:AssumeRole"
        }]
      })
    })

    role_policy = merge({ for k, v in yamldecode(templatefile(var.config_file, local.context)).role_policy : k => v }, {
      policy = jsonencode({
        "Version" : "2012-10-17"
        "Statement" : [
          {
            "Effect" : "Allow",
            "Resource" : "*"
            "Action" : [
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:ListBucket",
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams"
            ],
          }
        ],
      })
    })

    ec2 = { for k, v in yamldecode(templatefile(var.config_file, local.context)).ec2 : k => merge(v, {
      subnet_id              = local.subnet_groups_context[k]["${k}_subnets"][0]
      user_data              = k == "public" ? file("${path.module}/scripts/userdata.sh") : ""
      vpc_security_group_ids = [for k, v in local.security_groups_context : v.security_group_id]
    }) }

    ec2_instances_state = { for k, v in yamldecode(templatefile(var.config_file, local.context)).ec2_instances_state : k => v }

    eip = merge({ for k, v in yamldecode(templatefile(var.config_file, local.context)).eip : k => v }, {
      vpc = true
    })

    alb = merge({ for k, v in yamldecode(templatefile(var.config_file, local.context)).alb : k => v }, {
      subnets         = local.subnet_groups_context["public"]["public_subnets"]
      security_groups = [for k, v in local.security_groups_context : v["security_group_id"] if k == "http"]
    })

    alb_tg = merge({ for k, v in yamldecode(templatefile(var.config_file, local.context)).alb_tg : k => v }, {
      vpc_id = local.vpc_context.vpc_id
    })

    alb_tg_attachment = {
      port = local.context.app_port
    }

    alb_listener = { for k, v in yamldecode(templatefile(var.config_file, local.context)).alb_listener : k => v }

    launch_template = merge({ for k, v in yamldecode(templatefile(var.config_file, local.context)).launch_template : k => v }, {
      subnet_id              = local.subnet_groups_context["private"]["private_subnets"][0]
      user_data              = filebase64("${path.module}/scripts/userdata.sh")
      vpc_security_group_ids = [for k, v in local.security_groups_context : v["security_group_id"] if k == "http"]
    })

    asg = merge({ for k, v in yamldecode(templatefile(var.config_file, local.context)).asg : k => v }, {
      vpc_zone_identifier = local.subnet_groups_context["private"]["private_subnets"]
    })
  }

  output_search_set = {
    ec2          = ["arn", "id", "name", "instance_state", "private_ip", "public_ip", "tags_all"]
    ami          = ["arn", "id", "name", "source_instance_id"]
    eip          = ["id", "instance", "public_ip"]
    alb          = ["access_logs", "arn", "id", "internal", "ip_address_type", "name", "security_groups", "subnets", "vpc_id", "zone_id"]
    alb_tg       = ["arn", "id", "ip_address_type", "load_balancing_algorithm_type", "name", "port", "protocol", "target_type", "vpc_id"]
    alb_listener = ["arn", "id", "ip_address_type", "load_balancer_arn", "port", "protocol"]
    asg          = ["arn", "id", "ip_address_type", "load_balancing_algorithm_type", "name", "port", "protocol", "target_type", "vpc_id"]
  }
}