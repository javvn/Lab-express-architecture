module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = local.vpc_context.name
  cidr = local.vpc_context.cidr_block
  azs  = local.context.azs

  enable_ipv6             = local.vpc_context.enable_ipv6
  enable_vpn_gateway      = local.vpc_context.enable_vpn_gateway
  enable_nat_gateway      = local.vpc_context.enable_nat_gateway
  single_nat_gateway      = local.vpc_context.single_nat_gateway
  map_public_ip_on_launch = local.vpc_context.map_public_ip_on_launch
  create_igw              = local.vpc_context.create_igw

}