locals {
  common_tags             = data.terraform_remote_state.vpc.outputs.common_tags
  remote_context          = data.terraform_remote_state.vpc.outputs.context
  vpc_context             = data.terraform_remote_state.vpc.outputs.network.vpc
  subnet_groups_context   = data.terraform_remote_state.vpc.outputs.network.subnet_groups
  security_groups_context = data.terraform_remote_state.vpc.outputs.network.security_groups
  context                 = yamldecode(file(var.config_file)).context

  ec2_context = { for k, v in yamldecode(templatefile(var.config_file, local.context)).ec2 : k => merge(v, {
    subnet_id              = local.subnet_groups_context[k]["${k}_subnets"][0]
    user_data              = k == "private" ? file("${path.module}/scripts/userdata.sh") : ""
    vpc_security_group_ids = [for k, v in local.security_groups_context : v.security_group_id]
    tags                   = merge(local.common_tags, { Name = "${local.remote_context.name}-ec2-${k}" })
  }) }

  ec2_output_search_set = ["arn", "id", "instance_state", "private_ip", "public_ip", "tags_all"]

  eip_tags = merge(local.common_tags, { Name = "${local.remote_context.name}-eip" })
}