output "lambda_arn" {
  value = aws_lambda_function.hop_trigger.arn
}

output "lambda_name" {
  value = aws_lambda_function.hop_trigger.function_name
}