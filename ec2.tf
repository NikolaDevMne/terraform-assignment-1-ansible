resource "aws_key_pair" "ssh" {
  key_name   = "${var.name}-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1.1"

  ami = data.aws_ami.ubuntu.id

  name = "${var.name}-ec2"

  instance_type = "t3.micro"
  monitoring    = false
  subnet_id     = module.vpc.public_subnets[0]

  create_eip = true

  vpc_security_group_ids = [module.ssh_security_group.security_group_id, module.http_security_group.security_group_id]
  key_name               = aws_key_pair.ssh.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  tags = merge(
    {
      "Project" = var.name
      "Managed" = "terraform"
    },
    var.tags
  )
}
