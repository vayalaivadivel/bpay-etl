resource "terraform_data" "bootstrap" {

  depends_on = [
    aws_instance.bastion
  ]

  triggers_replace = [
    aws_instance.bastion.id
  ]

  connection {
    type        = "ssh"
    host        = aws_instance.bastion.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  #############################################
  # COPY SCRIPTS
  #############################################

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/home/ubuntu"
  }

  #############################################
  # COPY SQL FILES
  #############################################

  provisioner "file" {
    source      = "${path.module}/init-databases.sql.tpl"
    destination = "/home/ubuntu/init-databases.sql"
  }

  provisioner "file" {
    source      = "${path.module}/init-source.sql.tpl"
    destination = "/home/ubuntu/init-source.sql"
  }

  provisioner "file" {
    source      = "${path.module}/init-replicated.sql.tpl"
    destination = "/home/ubuntu/init-replicated.sql"
  }

  provisioner "file" {
    source      = "${path.module}/init-unified.sql.tpl"
    destination = "/home/ubuntu/init-unified.sql"
  }

  provisioner "file" {
    content = templatefile("${path.module}/bpay.env.tpl", {
      rds_host           = split(":", var.rds_endpoint)[0]
      db_user            = var.db_username
      db_password        = var.db_password
      db_name            = var.db_name
      replicated_db_name = var.replicated_db_name
      unified_db_name    = var.unified_db_name
    })

    destination = "/home/ubuntu/bpay.env"
  }

  #############################################
  # INITIALIZE DATABASE
  #############################################

  provisioner "remote-exec" {

    inline = [

      "chmod +x /home/ubuntu/scripts/*.sh",

      "export RDS_HOST='${split(":", var.rds_endpoint)[0]}'",
      "export DB_USER='${var.db_username}'",
      "export DB_PASSWORD='${var.db_password}'",
      "export DB_NAME='${var.db_name}'",

      "/home/ubuntu/scripts/init-db.sh",

      "/home/ubuntu/scripts/verify-db.sh"

    ]
  }
}