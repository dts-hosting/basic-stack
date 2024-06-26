terraform {
  backend "s3" {}
}

variable "config_file" {
}

locals {
  config_file         = var.config_file
  config_file_content = fileexists(local.config_file) ? file(local.config_file) : "NoSettingsFileFound: true"
  config              = yamldecode(local.config_file_content)

  # extract values from config
  instances       = local.config.instances
  name            = local.config.name
  resource_prefix = local.config.resource_prefix
  ssh_allowlist   = try(local.config.ssh_allowlist, ["0.0.0.0/0"])
  vpc_cidr_block  = try(local.config.vpc_cidr_block, "10.0.0.0/16")
}

provider "aws" {
  default_tags {
    tags = {
      Stack = local.name
    }
  }
}

module "basic-stack" {
  source = "../modules/basic-stack"

  instances       = local.instances
  name            = local.name
  resource_prefix = local.resource_prefix
  ssh_allowlist   = local.ssh_allowlist
  vpc_cidr_block  = local.vpc_cidr_block
}

output "dns_names" {
  value = module.basic-stack.dns_names
}

output "public_ips" {
  value = module.basic-stack.public_ips
}

output "security_group_id" {
  value = module.basic-stack.security_group_id
}

output "ssh_private_key" {
  value     = module.basic-stack.ssh_private_key
  sensitive = true
}

output "ssh_public_key" {
  value = module.basic-stack.ssh_public_key
}

output "subnet_id" {
  value = module.basic-stack.subnet_id
}

output "vpc_id" {
  value = module.basic-stack.vpc_id
}
