locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, 1)
  instances       = var.instances
  name            = var.name
  resource_prefix = var.resource_prefix
  ssh_allowlist   = join(",", var.ssh_allowlist)
  vpc_cidr_block  = var.vpc_cidr_block
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "selected" {
  for_each = { for i in local.instances : i.name => i }

  most_recent = true

  filter {
    name   = "name"
    values = [each.value.ami_distro]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [each.value.ami_owner]
}

output "security_group_id" {
  value = module.security.security_group_id
}

output "ssh_private_key" {
  value = module.key.private_key_pem
}

output "ssh_public_key" {
  value = module.key.public_key_pem
}

output "subnet_id" {
  description = "Subnet id of the first subnet created for this vpc"
  value       = element(module.vpc.public_subnets, 0)
}

output "vpc_id" {
  value = module.vpc.default_vpc_id
}
