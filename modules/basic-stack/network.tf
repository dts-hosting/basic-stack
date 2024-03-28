module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                    = local.resource_prefix
  cidr                    = local.vpc_cidr_block
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  # disable creation of "default" resources
  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  azs            = local.azs
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr_block, 8, k + 1)]
}
