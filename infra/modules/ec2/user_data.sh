#!/bin/bash

set -euo pipefail

#########################################
# LOGGING
#########################################

exec > >(tee /home/ubuntu/user-data.log) 2>&1

echo "===== STARTING USER DATA SCRIPT ====="

#########################################
# UPDATE SYSTEM
#########################################

echo "Updating system packages..."

apt-get update -y

#########################################
# INSTALL MYSQL CLIENT
#########################################

echo "Installing MySQL client..."

apt-get install -y mysql-client || \
apt-get install -y default-mysql-client || \
apt-get install -y mysql-client-core-8.0

#########################################
# VERIFY MYSQL CLIENT
#########################################

if ! command -v mysql >/dev/null 2>&1; then
    echo "❌ MySQL client installation failed"
    exit 1
fi

echo "✅ MySQL client installed successfully"

mysql --version

#########################################
# DISPLAY DATABASE INFO
#########################################

echo "Using RDS host: ${rds_host}"
echo "Using DB name: ${db_name}"

#########################################
# WAIT FOR RDS
#########################################

echo "Waiting for RDS to become available..."

RETRIES=30
COUNT=0

until mysql \
  -h "${rds_host}" \
  -u "${db_user}" \
  -p"${db_password}" \
  -e "SELECT 1" >/dev/null 2>&1
do

  COUNT=$((COUNT+1))

  echo "⏳ Attempt $COUNT/$RETRIES: RDS not ready yet..."

  if [ $COUNT -ge $RETRIES ]; then
    echo "❌ RDS not reachable after retries"
    exit 1
  fi

  sleep 10
done

echo "✅ RDS is ready"

#########################################
# CREATE SQL FILE
#########################################

echo "Creating SQL initialization file..."

echo "${init_sql_b64}" | base64 -d > /home/ubuntu/init.sql

chown ubuntu:ubuntu /home/ubuntu/init.sql
chmod 600 /home/ubuntu/init.sql

echo "✅ SQL file created"

#########################################
# EXECUTE SQL
#########################################

echo "Running database initialization..."

mysql \
  -h "${rds_host}" \
  -u "${db_user}" \
  -p"${db_password}" < /home/ubuntu/init.sql

#########################################
# VALIDATE DB INIT
#########################################

if [ $? -eq 0 ]; then
  echo "✅ DB initialized successfully" \
    | tee /home/ubuntu/db_init.log
else
  echo "❌ DB initialization failed" \
    | tee /home/ubuntu/db_init.log
  exit 1
fi

#########################################
# COMPLETE
#########################################

echo "===== USER DATA SCRIPT COMPLETED SUCCESSFULLY ====="