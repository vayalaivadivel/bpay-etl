resource "aws_iam_role" "dms_cloudwatch_logs_role" {

  name = "dms-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.app_name
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs" {

  role = aws_iam_role.dms_cloudwatch_logs_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}