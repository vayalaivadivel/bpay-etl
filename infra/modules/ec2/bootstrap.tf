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
  # BOOTSTRAP
  #############################################

  provisioner "remote-exec" {

    inline = [

      "sudo mkdir -p /opt/bpay/scripts",
      "sudo mkdir -p /opt/bpay/sql",

      "sudo cp -rf /home/ubuntu/scripts/* /opt/bpay/scripts/",
      "sudo cp -rf /home/ubuntu/ec2/* /opt/bpay/sql/",

      "sudo chmod +x /opt/bpay/scripts/*.sh",

      "echo '========================================'",
      "echo 'Scripts'",
      "echo '========================================'",
      "find /opt/bpay/scripts -type f",

      "echo '========================================'",
      "echo 'SQL Files'",
      "echo '========================================'",
      "find /opt/bpay/sql -type f",

      <<-EOT
        RDS_HOST='${split(":", var.rds_endpoint)[0]}' \
        DB_USER='${var.db_username}' \
        DB_PASSWORD='${var.db_password}' \
        DB_NAME='${var.db_name}' \
        bash -x /opt/bpay/scripts/init-db.sh
      EOT
      ,

      <<-EOT
        RDS_HOST='${split(":", var.rds_endpoint)[0]}' \
        DB_USER='${var.db_username}' \
        DB_PASSWORD='${var.db_password}' \
        DB_NAME='${var.db_name}' \
        bash -x /opt/bpay/scripts/verify-db.sh
      EOT

    ]
  }

}