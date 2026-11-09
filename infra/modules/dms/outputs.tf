output "dms_security_group_id" {
  value = aws_security_group.dms_sg.id
}

output "dms_replication_task_arn" {
  description = "DMS replication task ARN"
  value       = aws_dms_replication_task.mysql_cdc_task.replication_task_arn
}

output "dms_replication_instance_arn" {
  description = "DMS replication instance ARN"
  value       = aws_dms_replication_instance.dms_instance.replication_instance_arn
}