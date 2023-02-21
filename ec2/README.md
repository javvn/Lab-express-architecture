# ec2

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.3.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.55.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [null_resource.bastion](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ami.amazon](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | n/a | `string` | `"./config.yaml"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_ami"></a> [ec2\_ami](#output\_ec2\_ami) | n/a |
| <a name="output_ec2_context"></a> [ec2\_context](#output\_ec2\_context) | n/a |
| <a name="output_ec2_eip"></a> [ec2\_eip](#output\_ec2\_eip) | n/a |
| <a name="output_ec2_instances"></a> [ec2\_instances](#output\_ec2\_instances) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
