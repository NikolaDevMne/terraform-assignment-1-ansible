locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  vpc_cidr = var.vpc_cidr

  public_subnets  = [for i in range(2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnets = [for i in range(2) : cidrsubnet(local.vpc_cidr, 8, i + 100)]

  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}
