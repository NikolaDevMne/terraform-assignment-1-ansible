data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  vpc_cidr = var.vpc_cidr

  public_subnets  = [for i in range(2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnets = [for i in range(2) : cidrsubnet(local.vpc_cidr, 8, i + 100)]
}

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

resource "aws_key_pair" "ssh" {
  key_name   = "${var.name}-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

module "ssh_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${var.name}-ssh-sg"
  description = "Allow SSH access from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]


  tags = merge(
    {
      "Project" = var.name
      "Managed" = "terraform"
    },
    var.tags
  )
}

module "http_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${var.name}-http-sg"
  description = "Allow HTTP and HTTPS from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = merge(
    {
      "Project" = var.name
      "Managed" = "terraform"
    },
    var.tags
  )
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${var.name}-db-sg"
  description = "Allow DB access from EC2"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.ssh_security_group.security_group_id
    }
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = merge(
    { "Project" = var.name, "Managed" = "terraform" },
    var.tags
  )
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

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
  password = var.db_password
  port     = 3306

  multi_az = false

  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  vpc_security_group_ids = [module.db_security_group.security_group_id]

  skip_final_snapshot = true

  tags = merge(
    { "Project" = var.name, "Managed" = "terraform" },
    var.tags
  )
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.6"

  ami = data.aws_ami.ubuntu.id

  name = "${var.name}-ec2"

  instance_type = "t3.micro"
  monitoring    = false
  subnet_id     = module.vpc.public_subnets[0]

  create_eip = true

  vpc_security_group_ids = [module.ssh_security_group.security_group_id, module.http_security_group.security_group_id]
  key_name               = aws_key_pair.ssh.key_name

  tags = merge(
    {
      "Project" = var.name
      "Managed" = "terraform"
    },
    var.tags
  )
}
