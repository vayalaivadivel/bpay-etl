#########################################
# RDS SECURITY GROUP
#########################################

resource "aws_security_group" "rds" {

  name = "${var.app_name}-${var.env}-rds-sg"

  vpc_id = var.vpc_id

  #################################
  # EGRESS
  #################################

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  #################################
  # TAGS
  #################################

  tags = {

    Name = "${var.app_name}-${var.env}-rds-sg"

    Project = var.app_name

    Environment = var.env
  }
}