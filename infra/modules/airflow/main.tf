#########################################
# CLOUDWATCH LOG GROUP
#########################################

resource "aws_cloudwatch_log_group" "airflow" {

  name = "/ecs/${var.app_name}-airflow-${var.env}"

  retention_in_days = 7
}

#########################################
# ALB TARGET GROUP
#########################################

resource "aws_lb_target_group" "airflow" {

  name        = "${var.app_name}-airflow-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {

    path = "/health"

    matcher = "200-399"

    interval = 120

    timeout = 60

    healthy_threshold = 2

    unhealthy_threshold = 10
  }
}

#########################################
# ECS TASK DEFINITION
#########################################

resource "aws_ecs_task_definition" "airflow" {

  family = "${var.app_name}-airflow-${var.env}"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = 1024

  memory = 2048

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {

      name = "${var.app_name}-airflow"

      image = "${var.ecr_repository_url}:bpay-etl-airflow-${var.env}"

      essential = true

      ######################################################
      # PORTS
      ######################################################

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      ######################################################
      # ECS CONTAINER HEALTH CHECK
      ######################################################

      healthCheck = {

        command = [
          "CMD-SHELL",
          "curl -f http://localhost:8080/health || exit 1"
        ]

        interval    = 30
        timeout     = 10
        retries     = 5
        startPeriod = 120
      }

      ######################################################
      # ENVIRONMENT VARIABLES
      ######################################################

      environment = [

        ####################################################
        # AIRFLOW CORE
        ####################################################

        {
          name  = "AIRFLOW__CORE__LOAD_EXAMPLES"
          value = "False"
        },

        {
          name  = "AIRFLOW__CORE__EXECUTOR"
          value = "LocalExecutor"
        },

        ####################################################
        # MYSQL METADATA DATABASE
        ####################################################

        {
          name  = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
          value = "mysql+mysqldb://${var.db_username}:${var.db_password}@${var.rds_endpoint}:3306/airflow"
        },

        ####################################################
        # AIRFLOW WEBSERVER
        ####################################################

        {
          name  = "AIRFLOW__WEBSERVER__WEB_SERVER_HOST"
          value = "0.0.0.0"
        },

        {
          name  = "AIRFLOW__WEBSERVER__WEB_SERVER_PORT"
          value = "8080"
        },

        ####################################################
        # ALB + PROXY + PATH BASED ROUTING
        ####################################################

        {
          name  = "AIRFLOW__WEBSERVER__BASE_URL"
          value = "http://${var.env}-airflow.${var.domain_name}"
        },

        {
          name  = "AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX"
          value = "True"
        },

        {
          name  = "AIRFLOW__WEBSERVER__COOKIE_SAMESITE"
          value = "Lax"
        },

        {
          name  = "AIRFLOW__WEBSERVER__COOKIE_SECURE"
          value = "False"
        }
      ]

      ######################################################
      # CLOUDWATCH LOGS
      ######################################################

      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group = aws_cloudwatch_log_group.airflow.name

          awslogs-region = var.aws_region

          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

#########################################
# ECS SERVICE
#########################################

resource "aws_ecs_service" "airflow" {

  name = "${var.app_name}-airflow-service-${var.env}"

  cluster = var.ecs_cluster_id

  task_definition = aws_ecs_task_definition.airflow.arn

  desired_count = 1

  launch_type = "FARGATE"

  health_check_grace_period_seconds = 600

  network_configuration {

    subnets = var.public_subnets

    security_groups = [
      aws_security_group.airflow_sg.id
    ]

    assign_public_ip = true
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.airflow.arn

    container_name = "${var.app_name}-airflow"

    container_port = 8080
  }

  depends_on = [
    aws_lb_target_group.airflow
  ]
}

#########################################
# REDIRECT /airflow -> /airflow/
#########################################

resource "aws_lb_listener_rule" "airflow_redirect" {

  listener_arn = var.alb_listener_arn

  priority = 199

  action {

    type = "redirect"

    redirect {

      path = "/airflow/"

      port = "80"

      protocol = "HTTP"

      status_code = "HTTP_301"
    }
  }

  condition {

    path_pattern {

      values = ["/airflow"]
    }
  }
}

#########################################
# FORWARD /airflow/*
#########################################

resource "aws_lb_listener_rule" "airflow" {

  listener_arn = var.alb_listener_arn

  priority = 200

  action {

    type = "forward"

    target_group_arn = aws_lb_target_group.airflow.arn
  }

  condition {

    path_pattern {

      values = ["/airflow/*"]
    }
  }
}


resource "aws_lb_listener_rule" "airflow_host" {

  listener_arn = var.alb_listener_arn

  priority = 150

  action {

    type = "forward"

    target_group_arn = aws_lb_target_group.airflow.arn
  }

  condition {

    host_header {

      values = [
        "${var.env}-airflow.${var.domain_name}"
      ]
    }
  }

  tags = {

    Name = "${var.app_name}-airflow-host-rule-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}