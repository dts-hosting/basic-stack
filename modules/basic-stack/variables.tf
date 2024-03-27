variable "name" {
  description = "name of project"
}
variable "resource_prefix" {
  description = "name and / or prefix for created resources"
}
variable "ssh_allowlist" {
  description = "list of ip addresses permitted to connect over ssh"
  type        = list(string)
}
variable "vpc_cidr_block" {
  description = "cidr block for the vpc"
}
