data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../network/terraform.tfstate"
  }
}
data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.ec2_context

  ami                    = data.aws_ami.amazon.image_id
  name                   = each.value.name
  key_name               = each.value.key_name
  user_data              = each.value.user_data
  subnet_id              = each.value.subnet_id
  monitoring             = each.value.monitoring
  instance_type          = each.value.instance_type
  vpc_security_group_ids = each.value.vpc_security_group_ids

  tags = each.value.tags

  //  iam_instance_profile = aws_iam_instance_profile.ec2.name
}

resource "null_resource" "bastion" {
  triggers = {
    ec2_public_ip = aws_eip.bastion.public_ip
  }

  provisioner "local-exec" {
    command = "echo provisioner start"
  }

  provisioner "local-exec" {
    command = "if [ -z \"$(ssh-keygen -F ${aws_eip.bastion.public_ip})\" ]; then  ssh-keyscan -H ${aws_eip.bastion.public_ip} >> ~/.ssh/known_hosts; fi"
  }

  provisioner "local-exec" {
    command = "scp -i ${local.context.key_path}/${local.ec2_context.public.key_name}.pem ${local.context.key_path}/${local.ec2_context.public.key_name}.pem ec2-user@${aws_eip.bastion.public_ip}:/home/ec2-user/${local.ec2_context.public.key_name}.pem"

    connection {
      type = "ssh"
      user = "ec2-user"
      host = aws_eip.bastion.public_ip
    }
  }
}