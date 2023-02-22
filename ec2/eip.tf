//resource "aws_eip" "bastion" {
//  vpc      = local.resource_context.eip.vpc
//  instance = module.ec2.public.id
//  tags     = merge(local.common_tags, { Name = local.resource_context.eip.name })
//
//  depends_on = [module.ec2]
//}