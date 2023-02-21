locals {
  context = yamldecode(file(var.config_file)).context

  common_tags = {
    Project   = local.context.project
    Terraform = local.context.terraform
    Owner     = local.context.owner
    Env       = local.context.env
  }

  vpc_context             = yamldecode(templatefile(var.config_file, local.context)).network.vpc
  subnet_groups_context   = yamldecode(templatefile(var.config_file, local.context)).network.subnet_groups
  security_groups_context = yamldecode(templatefile(var.config_file, local.context)).network.security_groups

  vpc_search_set            = ["vpc_arn", "vpc_cidr_block", "vpc_id", "name", "azs"]
  igw_search_set            = ["igw_id", "igw_arn"]
  private_rt_search_set     = ["private_route_table_ids", "private_route_table_association_ids"]
  private_subnet_search_set = ["private_subnet_arns", "private_subnets", "private_subnets_cidr_blocks"]
  public_rt_search_set      = ["public_route_table_ids", "public_route_table_association_ids"]
  public_subnet_search_set  = ["public_subnet_arns", "public_subnets", "public_subnets_cidr_blocks"]


  vpc_tags = merge(local.common_tags, {
    Name = local.vpc_context.name
  })
  igw_tags = merge(local.common_tags, {
    Name = "${local.context.name}-igw"
  })
  public_subnet_tags = merge(local.common_tags, {
    Name = local.subnet_groups_context["public"].name
  })
  private_subnet_tags = merge(local.common_tags, {
    Name = local.subnet_groups_context["private"].name
  })
  public_route_table_tags = merge(local.common_tags, {
    Name = "${local.context.name}-public-rt"
  })
  private_route_table_tags = merge(local.common_tags, {
    Name = "${local.context.name}-private-rt"
  })
}