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
  -p"${db_password}" \
  --verbose \
  < /home/ubuntu/init.sql \
  > /home/ubuntu/init_execution.log 2>&1

MYSQL_RC=$?

if [ $MYSQL_RC -ne 0 ]; then
    echo "❌ Database initialization failed"
    cat /home/ubuntu/init_execution.log
    exit $MYSQL_RC
fi

echo "✅ Database initialization completed"

#########################################
# VERIFY DATA
#########################################

echo "Verifying database..."

mysql \
  -h "${rds_host}" \
  -u "${db_user}" \
  -p"${db_password}" \
<<EOF

USE ${db_name};

SELECT 'cardholders',COUNT(*) FROM cardholders
UNION ALL
SELECT 'cards',COUNT(*) FROM cards
UNION ALL
SELECT 'merchant_categories',COUNT(*) FROM merchant_categories
UNION ALL
SELECT 'transactions',COUNT(*) FROM transactions
UNION ALL
SELECT 'offers',COUNT(*) FROM offers
UNION ALL
SELECT 'campaigns',COUNT(*) FROM campaigns
UNION ALL
SELECT 'reward_points',COUNT(*) FROM reward_points;

EOF

echo "Database verification completed"