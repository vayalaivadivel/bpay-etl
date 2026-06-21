output "role_name" {
  value = aws_iam_role.this.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "dms_role_arn" {
  value = aws_iam_role.dms_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}
output "dms_vpc_role_ready" {

  value = aws_iam_role_policy_attachment.dms_vpc_attach.id
}

output "ecs_task_execution_role_arn" {

  value = aws_iam_role.ecs_task_execution.arn
}
output "dms_cloudwatch_role_dependency" {
  value = aws_iam_role.dms_cloudwatch_logs_role
}