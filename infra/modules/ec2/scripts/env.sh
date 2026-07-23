sudo tee /opt/bpay/scripts/env.sh >/dev/null <<EOF
export RDS_HOST=${split(":", var.rds_endpoint)[0]}
export DB_USER=${var.db_username}
export DB_PASSWORD='${var.db_password}'
export DB_NAME=${var.db_name}
EOF