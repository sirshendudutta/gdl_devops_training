# Notes:
# - 5 Security Groups are needed:
#   - For the ALB of the Web Tier
#   - For the ALB of the App Tier
#   - For the Web Tier (the ASG)
#   - For the App Tier (the ASG)
#   - For the Data Tier (attached to the RDS deployment)

# Security Group for the internet-facing ALB
resource "aws_security_group" "web_alb_sg" {
  name        = "${var.module_prefix}-web-alb-sg"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  # Ready for SSL/TLS certificate future use:
  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.module_prefix}-web-alb_sg"
  }
}

# Security Group for the internal ALB (beetween web and app tier)
resource "aws_security_group" "internal_alb_sg" {
  name        = "${var.module_prefix}-internal-alb-sg"
  description = "enable http access on port 80"
  vpc_id      = var.vpc_id

  ingress {
    description     = "enable http access from web tier sg"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "${var.module_prefix}-app-alb_sg"
  }
}

# Security Group for the Web Tier
resource "aws_security_group" "web_sg" {
  name        = "${var.module_prefix}-web-sg"
  description = "enable http access on port 80 for elb sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.module_prefix}-web_sg"
  }
}

# Security Group for the App Tier
resource "aws_security_group" "app_sg" {
  name        = "${var.module_prefix}-app-sg"
  description = "Enable http access on port 80 for elb sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb_sg.id]
  }

  tags = {
    Name = "${var.module_prefix}-app_sg"
  }
}

# Security Group for the Database (Data Tier)
resource "aws_security_group" "db_sg" {
  name        = "${var.module_prefix}-db-sg"
  description = "enable postgres access on port 5432 from app-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.module_prefix}-database_sg"
  }
}

# Separate security group rules to avoid circular dependency
resource "aws_security_group_rule" "app_to_db_egress" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db_sg.id
  security_group_id        = aws_security_group.app_sg.id
  description              = "Enable outbound comm with Postgres DB"
}

resource "aws_security_group_rule" "db_from_app_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.db_sg.id
  description              = "Postgres access from app tier"
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow outbound internet access"
}

resource "aws_security_group_rule" "internal_alb_to_app_egress" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.internal_alb_sg.id
  description              = "Enable outbound http access to app tier sg"
}

resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow all outbound traffic"
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
