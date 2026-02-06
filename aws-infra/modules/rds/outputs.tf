output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "address" {
  value = aws_db_instance.postgres.address
}
