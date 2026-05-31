resource "null_resource" "create_databases" {

  provisioner "local-exec" {

    command = <<EOT
mysql \
-h ${var.rds_host} \
-u ${var.db_user} \
-p${var.db_password} \
-e "
CREATE DATABASE IF NOT EXISTS ${var.raw_db_name};
CREATE DATABASE IF NOT EXISTS ${var.replicated_db_name};
CREATE DATABASE IF NOT EXISTS ${var.unified_db_name};
"
EOT
  }

  triggers = {
    raw_db        = var.raw_db_name
    replicated_db = var.replicated_db_name
    unified_db    = var.unified_db_name
  }
}