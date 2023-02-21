//output "remote_state" {
//  value = {
//    context         = local.remote_context
//    vpc             = local.vpc_context
//    subnet_groups   = local.subnet_groups_context
//    security_groups = local.security_groups_context
//  }
//}

output "ec2_context" {
  value = local.ec2_context
}

output "ec2_eip" {
  value = aws_eip.bastion
}

output "ec2_instances" {
  value = { for root_k, root_v in module.ec2 : root_k => { for child_k, child_v in root_v : child_k => child_v if contains(local.ec2_output_search_set, child_k) } }
}

output "ec2_ami" {

}
