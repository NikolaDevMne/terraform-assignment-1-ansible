resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-ec2-instance-profile"
  role = aws_iam_role.ec2.name
}

# Trust policy for EC2
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

# Read-only access to the specific RDS master secret
data "aws_iam_policy_document" "read_rds_secret" {
  statement {
    sid    = "ReadRdsMasterSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [module.db.db_instance_master_user_secret_arn]
  }
}

resource "aws_iam_policy" "read_rds_secret" {
  name       = "${var.name}-read-rds-secret"
  path       = "/"
  policy     = data.aws_iam_policy_document.read_rds_secret.json
  depends_on = [module.db] # ensure ARN is known
}

resource "aws_iam_role_policy_attachment" "attach_read_secret" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.read_rds_secret.arn
}
