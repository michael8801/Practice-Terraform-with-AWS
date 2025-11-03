data "aws_availability_zones" "available" {}

locals {
  azs = data.aws_availability_zones.available.names
  public_subnets = [
    for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  private_subnets = [
    for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i + length(local.azs))
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = var.instance_name
  cidr = var.vpc_cidr

  azs            = local.azs
  public_subnets = local.public_subnets

  private_subnets = local.private_subnets
  map_public_ip_on_launch = false

  enable_nat_gateway = true
  single_nat_gateway = true

  create_igw = true
}