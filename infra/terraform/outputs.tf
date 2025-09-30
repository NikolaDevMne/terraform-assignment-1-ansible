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

output "rds_endpoint" {
  value = module.db.db_instance_endpoint
}

output "rds_master_secret_arn" {
  value = module.db.db_instance_master_user_secret_arn
}

output "db_address" { value = module.db.db_instance_address }