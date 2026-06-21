#########################################
# EC2 ROLE
#########################################

resource "aws_iam_role" "this" {

  name = "${var.app_name}-${var.env}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

#########################################
# EC2 INSTANCE PROFILE
#########################################

resource "aws_iam_instance_profile" "this" {

  name = "${var.role_name}-profile"

  role = aws_iam_role.this.name
}

#########################################
# LAMBDA ROLE
#########################################

resource "aws_iam_role" "lambda_role" {

  name = "${var.app_name}-${var.env}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#########################################
# LAMBDA BASIC EXECUTION POLICY
#########################################

resource "aws_iam_role_policy_attachment" "lambda_basic" {

  role = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#########################################
# DMS VPC ROLE
#########################################

resource "aws_iam_role" "dms_vpc_role" {

  name = "dms-vpc-role"

  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

#########################################
# DMS VPC POLICY ATTACHMENT
#########################################

resource "aws_iam_role_policy_attachment" "dms_vpc_attach" {

  role = aws_iam_role.dms_vpc_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}


#########################################
# DMS ACCESS ROLE
#########################################

resource "aws_iam_role" "dms_role" {

  name = "${var.app_name}-${var.env}-dms-role"

  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

#########################################
# DMS ACCESS POLICY ATTACHMENT
#########################################

resource "aws_iam_role_policy_attachment" "dms_attach" {

  role = aws_iam_role.dms_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

############################################################
# ECS TASK EXECUTION ROLE
############################################################

resource "aws_iam_role" "ecs_task_execution" {

  name = "${var.app_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################################
# ECS TASK EXECUTION POLICY ATTACHMENT
############################################################

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {

  role = aws_iam_role.ecs_task_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}