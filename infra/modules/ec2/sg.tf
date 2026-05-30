resource "aws_security_group" "bastion_sg" {

  name = "${var.app_name}-bastion-sg-${var.env}"

  vpc_id = var.vpc_id

  #########################################
  # SSH
  #########################################

  ingress {

    description = "SSH access"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  #########################################
  # HOP
  #########################################

  ingress {

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    from_port = 8081

    to_port = 8081

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  #########################################
  # EGRESS
  #########################################

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  #########################################
  # TAGS
  #########################################

  tags = {

    Name = "${var.app_name}-bastion-sg-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}