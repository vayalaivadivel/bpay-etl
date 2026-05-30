#########################################
# CREATE ZIP FROM PYTHON FILE
#########################################

data "archive_file" "lambda_zip" {

  type = "zip"

  source_file = "${path.module}/lambda/trigger_hop.py"

  output_path = "${path.module}/lambda/function.zip"
}

#########################################
# LAMBDA FUNCTION
#########################################

resource "aws_lambda_function" "hop_trigger" {

  function_name = "${var.app_name}-${var.env}-hop-workflow-trigger"

  filename = data.archive_file.lambda_zip.output_path

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = var.lambda_role_arn

  handler = "trigger_hop.lambda_handler"

  runtime = "python3.11"

  timeout = 60

  environment {

    variables = {

      HOP_URL = var.hop_url

      HOP_USERNAME = var.hop_username

      HOP_PASSWORD = var.hop_password
    }
  }

  tags = {

    Project = var.app_name

    Environment = var.env
  }
}