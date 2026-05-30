############################################################
# CLOUDWATCH LOG GROUP
############################################################

resource "aws_cloudwatch_log_group" "hop" {

  name = "/ecs/${var.app_name}-hop-${var.env}"

  retention_in_days = 7
}

############################################################
# ECS CLUSTER
############################################################

resource "aws_ecs_cluster" "hop" {

  name = "${var.app_name}-ecs-${var.env}"
}

############################################################
# ECS SECURITY GROUP
############################################################

resource "aws_security_group" "hop_ecs" {

  name = "${var.app_name}-hop-ecs-sg-${var.env}"

  vpc_id = var.vpc_id

  ##########################################################
  # HOP SERVER PORT
  ##########################################################

  ingress {

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    security_groups = [
      aws_security_group.hop_alb.id
    ]
  }

  ##########################################################
  # EGRESS
  ##########################################################

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################################
# ALB SECURITY GROUP
############################################################

resource "aws_security_group" "hop_alb" {

  name = "${var.app_name}-alb-sg-${var.env}"

  vpc_id = var.vpc_id

  ##########################################################
  # HTTP
  ##########################################################

  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ##########################################################
  # EGRESS
  ##########################################################

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################################
# APPLICATION LOAD BALANCER
############################################################

resource "aws_lb" "hop" {

  name = "${var.app_name}-alb-${var.env}"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.hop_alb.id
  ]

  subnets = var.public_subnets
}
############################################################
# TARGET GROUP
############################################################

resource "aws_lb_target_group" "hop" {

  name = "${var.app_name}-hop-tg-${var.env}"

  port = 8080

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = var.vpc_id

  lifecycle {

    create_before_destroy = true
  }

  ##########################################################
  # HEALTH CHECK
  ##########################################################

  health_check {

    enabled = true

    healthy_threshold = 2

    unhealthy_threshold = 5

    interval = 60

    timeout = 30

    path = "/status"

    protocol = "HTTP"

    matcher = "200-399"
  }
}

############################################################
# LISTENER
############################################################

resource "aws_lb_listener" "hop" {

  load_balancer_arn = aws_lb.hop.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.hop.arn
  }
}

############################################################
# ECS TASK DEFINITION
############################################################

resource "aws_ecs_task_definition" "hop" {

  family = "${var.app_name}-hop-${var.env}"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = "1024"

  memory = "2048"

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([

    {

      name = "${var.app_name}-hop"

      image = "${var.ecr_repository_url}:bpay-etl-hop-${var.env}"

      essential = true

      portMappings = [

        {

          containerPort = 8080

          hostPort = 8080

          protocol = "tcp"
        }
      ]

      ######################################################
      # CLOUDWATCH LOGS
      ######################################################

      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group = aws_cloudwatch_log_group.hop.name

          awslogs-region = var.aws_region

          awslogs-stream-prefix = "hop-server"
        }
      }
    }
  ])
}

############################################################
# ECS SERVICE
############################################################

resource "aws_ecs_service" "hop" {

  name = "${var.app_name}-hop-service-${var.env}"

  cluster = aws_ecs_cluster.hop.id

  task_definition = aws_ecs_task_definition.hop.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {

    subnets = var.private_subnets

    security_groups = [
      aws_security_group.hop_ecs.id
    ]

    assign_public_ip = false
  }

  ##########################################################
  # LOAD BALANCER
  ##########################################################

  load_balancer {

    target_group_arn = aws_lb_target_group.hop.arn

    container_name = "${var.app_name}-hop"

    container_port = 8080
  }

  depends_on = [
    aws_lb_listener.hop
  ]
}