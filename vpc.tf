module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.name}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  create_igw         = true
  enable_nat_gateway = false

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      "Project" = var.name
      "Managed" = "terraform"
    },
    var.tags
  )
}