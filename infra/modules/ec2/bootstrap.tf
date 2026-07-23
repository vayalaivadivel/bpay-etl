resource "null_resource" "bootstrap" {

  depends_on = [
    aws_instance.bastion,
    local_file.init_databases,
    local_file.init_source,
    local_file.init_replicated,
    local_file.init_unified
  ]

  triggers = {
    bastion_id = aws_instance.bastion.id
  }

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
  # COPY RENDERED SQL
  #############################################

  provisioner "file" {
    source      = "${path.root}/.terraform-rendered/ec2"
    destination = "/home/ubuntu"
  }

  #############################################
  # INITIALIZE DATABASE
  #############################################

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/bpay/scripts",
      "sudo mkdir -p /opt/bpay/sql",

      "sudo cp -r /home/ubuntu/scripts/* /opt/bpay/scripts/",
      "sudo cp -r /home/ubuntu/ec2/* /opt/bpay/sql/",

      "sudo chmod +x /opt/bpay/scripts/*.sh",

      "echo '===== Scripts ====='",
      "ls -lrt /opt/bpay/scripts",

      "echo '===== SQL ====='",
      "ls -lrt /opt/bpay/sql",

      # Export environment variables
      "export RDS_HOST=${split(":", var.rds_endpoint)[0]}",
      "export DB_USER=${var.db_username}",
      "export DB_PASSWORD='${var.db_password}'",
      "export DB_NAME=${var.db_name}",

      "echo RDS_HOST=$RDS_HOST",
      "echo DB_USER=$DB_USER",
      "echo DB_NAME=$DB_NAME",

      "bash -x /opt/bpay/scripts/init-db.sh",
      "bash -x /opt/bpay/scripts/verify-db.sh",

      "echo '===== Scripts ====='",
      "ls -lrt /opt/bpay/scripts",

      "echo '===== SQL ====='",
      "ls -lrt /opt/bpay/sql",

      "RDS_HOST='${split(":", var.rds_endpoint)[0]}' DB_USER='${var.db_username}' DB_PASSWORD='${var.db_password}' DB_NAME='${var.db_name}' bash -x /opt/bpay/scripts/init-db.sh",

      "RDS_HOST='${split(":", var.rds_endpoint)[0]}' DB_USER='${var.db_username}' DB_PASSWORD='${var.db_password}' DB_NAME='${var.db_name}' bash -x /opt/bpay/scripts/verify-db.sh"
    ]
  }


}