module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.12"

  identifier = "${var.name}-db"

  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100

  family               = "mysql8.0"
  major_engine_version = "8.0"

  db_name  = "appdb"
  username = "admin"

  manage_master_user_password = true

  port = 3306

  multi_az = false

  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  vpc_security_group_ids = [module.db_security_group.security_group_id]

  skip_final_snapshot = true

  publicly_accessible             = false
  deletion_protection             = false
  backup_retention_period         = 0
  storage_type                    = "gp3"
  auto_minor_version_upgrade      = true
  enabled_cloudwatch_logs_exports = ["general", "slowquery"]
  apply_immediately               = true


  tags = merge(
    { "Project" = var.name, "Managed" = "terraform" },
    var.tags
  )
}



