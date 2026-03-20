output "db_endpoint" {
  value = aws_db_instance.db.address
}

output "db_port" {
  value = aws_db_instance.db.port
}

output "db_name" {
  value = aws_db_instance.db.db_name
}
