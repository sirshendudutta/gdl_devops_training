
resource "aws_db_subnet_group" "db-subnet" {
  name       = "${var.module_prefix}-db-subnet-group"
  subnet_ids = [var.pri_sub_data_a_id, var.pri_sub_data_b_id]
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group



resource "aws_db_instance" "db" {
  identifier              = "${var.module_prefix}-db"
  engine                 = "postgres"
  engine_version         = "18"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = var.max_allocated_storage
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  multi_az                = true
  storage_type            = "gp2"
  storage_encrypted       = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  vpc_security_group_ids = [var.db_sg_id]

  db_subnet_group_name = aws_db_subnet_group.db-subnet.name

  tags = {
    Name = "bookdb"
  }
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
