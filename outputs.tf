output "vpc_id" {
  value = module.vpc.vpc_id
}

output "azs" {
  value = module.vpc.azs
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "instance_id" {
  value = module.ec2_instance.id
}

output "instance_public_ip" {
  value = try(module.ec2_instance.public_ip, null)
}