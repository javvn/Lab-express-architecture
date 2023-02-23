resource "aws_iam_role" "ec2" {
  name               = local.resource_context.role.name
  assume_role_policy = local.resource_context.role.assume_role_policy
}

resource "aws_iam_role_policy" "ec2" {
  role   = aws_iam_role.ec2.id
  name   = local.resource_context.role_policy.name
  policy = local.resource_context.role_policy.policy
}

resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.ec2.name
  role = aws_iam_role.ec2.name
}