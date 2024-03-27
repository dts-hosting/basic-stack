module "instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = { for i in local.instances : i.name => i }

  name = "${local.resource_prefix}-${each.key}"

  ami                         = data.aws_ami.selected[each.key].id
  associate_public_ip_address = true
  availability_zone           = element(module.vpc.azs, 0)
  ignore_ami_changes          = true
  instance_type               = each.value.type
  key_name                    = module.key.key_pair_name
  monitoring                  = false
  vpc_security_group_ids      = [module.security.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets, 0)

  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = each.value.root_volume_size
      volume_type           = "gp3"
    }
  ]

  user_data_base64            = base64encode(try(each.value.user_data, "#!/bin/bash"))
  user_data_replace_on_change = true
}

module "key" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "${local.resource_prefix}-key"
  create_private_key = true
}
