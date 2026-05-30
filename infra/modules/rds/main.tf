#########################################
# RDS SUBNET GROUP
#########################################

resource "aws_db_subnet_group" "this" {

  name = "${var.app_name}-${var.env}-rds-subnet"

  subnet_ids = var.private_subnets

  tags = {

    Name = "${var.app_name}-${var.env}-rds-subnet"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# MYSQL CDC PARAMETER GROUP
#########################################

resource "aws_db_parameter_group" "mysql_cdc_pg" {

  name = "${var.app_name}-${var.env}-mysql-cdc-pg"

  family = "mysql8.0"

  description = "Parameter group for MySQL CDC using AWS DMS"

  #################################
  # REQUIRED FOR CDC
  #################################

  parameter {

    name = "binlog_format"

    value = "ROW"
  }

  parameter {

    name = "binlog_row_image"

    value = "FULL"
  }

  parameter {

    name = "log_bin_trust_function_creators"

    value = "1"
  }

  #################################
  # TAGS
  #################################

  tags = {

    Name = "${var.app_name}-${var.env}-mysql-cdc-pg"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# MYSQL RDS
#########################################

resource "aws_db_instance" "mysql" {

  identifier = "${var.app_name}-db-${var.env}"

  db_name = var.db_name

  #################################
  # ENGINE
  #################################

  engine = "mysql"

  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  storage_type = "gp3"

  #################################
  # CREDENTIALS
  #################################

  username = var.username

  password = var.password

  #################################
  # NETWORK
  #################################

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  #################################
  # CDC PARAMETER GROUP
  #################################

  parameter_group_name = aws_db_parameter_group.mysql_cdc_pg.name

  #################################
  # BACKUP
  #################################

  backup_retention_period = 1

  delete_automated_backups = false

  #################################
  # LOGS
  #################################

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]

  #################################
  # IMPORTANT
  #################################

  apply_immediately = true

  skip_final_snapshot = true

  #################################
  # TIMEOUTS
  #################################

  timeouts {

    create = "30m"

    delete = "30m"
  }

  #################################
  # TAGS
  #################################

  tags = {

    Name = "${var.app_name}-db-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}