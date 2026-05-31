resource "aws_instance" "bastion" {

  ami = var.ami

  instance_type = "t3.micro"

  subnet_id = var.public_subnet_id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  key_name = var.key_name

  user_data = templatefile(
    "${path.module}/user_data.sh",
    {

      rds_host = split(":", var.rds_endpoint)[0]

      db_user = var.db_username

      db_password = var.db_password

      db_name = var.db_name

      user_data = templatefile(
        "${path.module}/user_data.sh",
        {

          rds_host = split(":", var.rds_endpoint)[0]

          db_user = var.db_username

          db_password = var.db_password

          db_name = var.db_name

          init_sql_b64 = base64encode(
            templatefile(
              "${path.module}/init.sql.tpl",
              {

                raw_db_name = var.raw_db_name

                replicated_db_name = var.replicated_db_name

                unified_db_name = var.unified_db_name

                db_name = var.db_name
              }
            )
          )
        }
      )
    }
  )

  tags = {

    Name = "${var.app_name}-bastion-${var.env}"

    Project = var.app_name

    Environment = var.env

    Version = "v2"
  }

  user_data_replace_on_change = true

  iam_instance_profile = var.instance_profile_name
}