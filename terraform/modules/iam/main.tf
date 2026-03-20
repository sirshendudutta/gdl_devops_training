resource "aws_iam_role" "ec2_role" {
  name               = "${var.module_prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.module_prefix}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_read_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

locals {
  ssm_parameter_path = trim(var.ssm_parameter_path_prefix, "/")
  ssm_parameter_arn  = local.ssm_parameter_path == "" ? "arn:aws:ssm:${var.region}:*:parameter/*" : "arn:aws:ssm:${var.region}:*:parameter/${local.ssm_parameter_path}/*"
}

resource "aws_iam_role_policy" "ssm_parameter_read" {
  name = "${var.module_prefix}-ssm-parameter-read"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = local.ssm_parameter_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.module_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name = "${var.module_prefix}-ec2-profile"
  }
}
