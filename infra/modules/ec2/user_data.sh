#!/bin/bash

set -euo pipefail

exec > >(tee /var/log/user-data.log) 2>&1

echo "=========================================="
echo "BPAY ETL EC2 BOOTSTRAP"
echo "=========================================="

apt-get update -y

apt-get install -y mysql-client \
|| apt-get install -y default-mysql-client \
|| apt-get install -y mysql-client-core-8.0

chmod +x /opt/bpay/scripts/*.sh

echo "Starting database initialization..."

/opt/bpay/scripts/init-db.sh

echo "Running verification..."

/opt/bpay/scripts/verify-db.sh

echo "Bootstrap completed."