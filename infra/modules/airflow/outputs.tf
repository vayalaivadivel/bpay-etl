output "airflow_service_name" {

  value = aws_ecs_service.airflow.name
}

output "airflow_target_group_arn" {

  value = aws_lb_target_group.airflow.arn
}

output "airflow_security_group_id" {

  value = aws_security_group.airflow_sg.id
}