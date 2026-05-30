
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
  # INGRESS
  #################################

  #################################
  # INGRESS
  #################################

  ingress {

    description = "MySQL from DMS"

    from_port = 3306

    to_port = 3306

    protocol = "tcp"

    security_groups = [
      var.dms_security_group_id
    ]
  }

  #########################################################
  # MYSQL FROM AIRFLOW ECS
  #########################################################

  ingress {

    description = "MySQL from Airflow ECS"

    from_port = 3306

    to_port = 3306

    protocol = "tcp"

    security_groups = [
      var.airflow_security_group_id
    ]
  }

  #########################################################
  # MYSQL FROM BASTION
  #########################################################

  ingress {

    description = "MySQL from Bastion"

    from_port = 3306

    to_port = 3306

    protocol = "tcp"

    security_groups = [
      var.bastion_security_group_id
    ]
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
