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
    destination = "/opt/bpay"
  }

  #############################################
  # COPY SQL FILES
  #############################################

  provisioner "file" {
    source      = "${path.module}/init-databases.sql.tpl"
    destination = "/opt/bpay/sql/init-databases.sql"
  }

  provisioner "file" {
    source      = "${path.module}/init-source.sql.tpl"
    destination = "/opt/bpay/sql/init-source.sql"
  }

  provisioner "file" {
    source      = "${path.module}/init-replicated.sql.tpl"
    destination = "/opt/bpay/sql/init-replicated.sql"
  }

  provisioner "file" {
    source      = "${path.module}/init-unified.sql.tpl"
    destination = "/opt/bpay/sql/init-unified.sql"
  }

  #############################################
  # INITIALIZE DATABASE
  #############################################

  provisioner "remote-exec" {

    inline = [
      <<-EOT
set -e

chmod +x /opt/bpay/scripts/*.sh

export RDS_HOST="${split(":", var.rds_endpoint)[0]}"
export DB_USER="${var.db_username}"
export DB_PASSWORD="${var.db_password}"
export DB_NAME="${var.db_name}"
export REPLICATED_DB_NAME="${var.replicated_db_name}"
export UNIFIED_DB_NAME="${var.unified_db_name}"

echo "Initializing database..."
bash /opt/bpay/scripts/init-db.sh

echo "Verifying database..."
bash /opt/bpay/scripts/verify-db.sh

echo "Bootstrap completed successfully."
EOT
    ]
  }
}