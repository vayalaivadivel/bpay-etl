resource "aws_security_group" "airflow_sg" {

  name = "${var.app_name}-airflow-sg-${var.env}"

  vpc_id = var.vpc_id

  ingress {

    from_port = 8080
    to_port   = 8080

    protocol = "tcp"

    security_groups = [var.alb_security_group_id]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "${var.app_name}-airflow-sg-${var.env}"
  }
}