#########################################
# DMS REPLICATION SUBNET GROUP
#########################################

resource "aws_dms_replication_subnet_group" "this" {

  replication_subnet_group_id = "${var.app_name}-${var.env}-dms-subnet-group"

  replication_subnet_group_description = "DMS subnet group"

  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.app_name}-${var.env}-dms-subnet-group"
  }

  depends_on = [
    var.dms_vpc_role_dependency
  ]
}

#########################################
# DMS SECURITY GROUP
#########################################

resource "aws_security_group" "dms_sg" {

  name = "${var.app_name}-${var.env}-dms-sg"

  vpc_id = var.vpc_id

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "${var.app_name}-${var.env}-dms-sg"
  }
}

#########################################
# DMS REPLICATION INSTANCE
#########################################

resource "aws_dms_replication_instance" "dms_instance" {

  replication_instance_id = "${var.app_name}-${var.env}-dms-instance"

  replication_instance_class = "dms.t3.small"

  allocated_storage = 20

  publicly_accessible = true

  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id

  vpc_security_group_ids = [
    aws_security_group.dms_sg.id
  ]

  multi_az = false

  auto_minor_version_upgrade = true

  apply_immediately = true

  depends_on = [
    aws_dms_replication_subnet_group.this,
    var.dms_vpc_role_dependency
  ]

  timeouts {

    create = "30m"

    delete = "30m"
  }

  tags = {

    Name = "${var.app_name}-${var.env}-dms-instance"
  }
}

#########################################
# MYSQL SOURCE ENDPOINT
#########################################

resource "aws_dms_endpoint" "mysql_source" {

  endpoint_id = "${var.app_name}-${var.env}-mysql-source"

  endpoint_type = "source"

  engine_name = "mysql"

  server_name = var.mysql_host

  port = 3306

  username = var.mysql_user

  password = var.mysql_password

  database_name = var.mysql_database

  ssl_mode = "none"

  tags = {

    Name = "${var.app_name}-${var.env}-mysql-source"
  }
}

#########################################
# MYSQL TARGET ENDPOINT
#########################################

resource "aws_dms_endpoint" "mysql_target" {

  endpoint_id = "${var.app_name}-${var.env}-mysql-target"

  endpoint_type = "target"

  engine_name = "mysql"

  server_name = var.mysql_host

  port = 3306

  username = var.mysql_user

  password = var.mysql_password

  database_name = var.raw_db_name

  ssl_mode = "none"

  tags = {

    Name = "${var.app_name}-${var.env}-mysql-target"
  }
}

#########################################
# DMS REPLICATION TASK
#########################################

resource "aws_dms_replication_task" "mysql_cdc_task" {

  replication_task_id = "${var.app_name}-${var.env}-mysql-cdc-task"

  migration_type = "full-load-and-cdc"

  replication_instance_arn = aws_dms_replication_instance.dms_instance.replication_instance_arn

  source_endpoint_arn = aws_dms_endpoint.mysql_source.endpoint_arn

  target_endpoint_arn = aws_dms_endpoint.mysql_target.endpoint_arn

  table_mappings = jsonencode({

    rules = [

      {

        "rule-type" = "selection"

        "rule-id" = "1"

        "rule-name" = "1"

        "object-locator" = {

          "schema-name" = "rldb"

          "table-name" = "offer"
        }

        "rule-action" = "include"
      }
    ]
  })

  replication_task_settings = jsonencode({

    FullLoadSettings = {

      TargetTablePrepMode = "DROP_AND_CREATE"

      CreatePkAfterFullLoad = false

      StopTaskCachedChangesApplied = false

      StopTaskCachedChangesNotApplied = false

      MaxFullLoadSubTasks = 8
    }

    Logging = {

      EnableLogging = true
    }

    TargetMetadata = {

      TargetSchema = ""

      SupportLobs = true

      FullLobMode = false

      LobChunkSize = 64

      LimitedSizeLobMode = true

      LobMaxSize = 32
    }
  })

  depends_on = [
    aws_dms_endpoint.mysql_source,
    aws_dms_endpoint.mysql_target,
    aws_dms_replication_instance.dms_instance
  ]

  tags = {

    Name = "${var.app_name}-${var.env}-mysql-cdc-task"
  }
}