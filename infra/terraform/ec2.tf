resource "aws_key_pair" "ssh" {
  count      = var.ssh_public_key == "" ? 0 : 1
  key_name   = "${var.name}-key"
  public_key = var.ssh_public_key
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1.1"

  ami  = data.aws_ami.ubuntu.id
  name = "${var.name}-ec2"

  instance_type = "t3.micro"
  monitoring    = false
  subnet_id     = module.vpc.public_subnets[0]

  create_eip = true

  vpc_security_group_ids = [module.ssh_security_group.security_group_id, module.http_security_group.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  key_name = var.ssh_public_key == "" ? null : aws_key_pair.ssh[0].key_name

  tags = merge(
    {
      "Project" = var.name
      "Managed" = "terraform"
      "Role"    = "web"
    },
    var.tags
  )
}
