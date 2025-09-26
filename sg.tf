module "ssh_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${var.name}-ssh-sg"
  description = "Allow SSH access from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = [local.my_ip_cidr]

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
      source_security_group_id = module.http_security_group.security_group_id
    }
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = merge(
    { "Project" = var.name, "Managed" = "terraform" },
    var.tags
  )
}
