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

  for_each = local.resource_context.ec2

  ami                    = data.aws_ami.amazon.image_id
  name                   = each.value.name
  key_name               = each.value.key_name
  user_data              = each.value.user_data
  subnet_id              = each.value.subnet_id
  monitoring             = each.value.monitoring
  instance_type          = each.value.instance_type
  vpc_security_group_ids = each.value.vpc_security_group_ids
  tags                   = merge(local.common_tags, { Name = each.value.name })
  //  iam_instance_profile = aws_iam_instance_profile.ec2.name
}

resource "null_resource" "bastion" {
  triggers = {
    //    ec2_public_ip = aws_eip.bastion.public_ip
    instance_id = module.ec2["public"].id
  }

  provisioner "local-exec" {
    command = "echo ########### PROVISIONER START ##############"
  }

  provisioner "local-exec" {
    //    command = "if [ -z \"$(ssh-keygen -F ${aws_eip.bastion.public_ip})\" ]; then  ssh-keyscan -H ${aws_eip.bastion.public_ip} >> ~/.ssh/known_hosts; fi"
    command = "if [ -z \"$(ssh-keygen -F ${module.ec2.public.public_ip})\" ]; then  ssh-keyscan -H ${module.ec2.public.public_ip} >> ~/.ssh/known_hosts; fi"
  }

  provisioner "local-exec" {
    command = "scp -i ${local.context.key_path}/${local.resource_context.ec2.public.key_name}.pem ${local.context.key_path}/${local.resource_context.ec2.public.key_name}.pem ec2-user@${module.ec2.public.public_ip}:/home/ec2-user/${local.resource_context.ec2.public.key_name}.pem"

    connection {
      type = "ssh"
      user = "ec2-user"
      host = module.ec2.public.public_ip
      //      host = aws_eip.bastion.public_ip
    }
  }
}

resource "aws_launch_template" "this" {
  name                                 = local.resource_context.launch_template.name
  description                          = local.resource_context.launch_template.description
  key_name                             = local.resource_context.launch_template.key_name
  user_data                            = local.resource_context.launch_template.user_data
  image_id                             = data.aws_ami.amazon.image_id
  instance_type                        = local.resource_context.launch_template.instance_type
  instance_initiated_shutdown_behavior = local.resource_context.launch_template.instance_initiated_shutdown_behavior
  tags                                 = merge(local.common_tags, { Name = local.resource_context.launch_template.name })

  monitoring {
    enabled = local.resource_context.launch_template.monitoring
  }

  network_interfaces {
    subnet_id       = local.resource_context.launch_template.subnet_id
    security_groups = local.resource_context.launch_template.vpc_security_group_ids
  }

  tag_specifications {
    resource_type = local.resource_context.launch_template.tag_spec.resource_type
    tags          = merge(local.common_tags, { Name = local.resource_context.launch_template.tag_spec.name })
  }
}