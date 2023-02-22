resource "aws_eip" "bastion" {
  instance = module.ec2.public.id
  vpc      = true
  tags     = local.eip_tags

  depends_on = [
    module.ec2
  ]
}