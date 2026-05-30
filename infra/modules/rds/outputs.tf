output "db_name" {
  value = var.db_name
}
output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}