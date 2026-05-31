resource "null_resource" "create_databases" {

  provisioner "local-exec" {

    interpreter = ["/bin/bash", "-c"]

    command = <<-EOT
mysql -h "${var.rds_host}" \
-u "${var.db_user}" \
-p"${var.db_password}" \
-e "
CREATE DATABASE IF NOT EXISTS ${var.raw_db_name};
CREATE DATABASE IF NOT EXISTS ${var.replicated_db_name};
CREATE DATABASE IF NOT EXISTS ${var.unified_db_name};
"
EOT
  }
}