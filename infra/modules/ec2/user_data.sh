#!/bin/bash

set -euo pipefail

exec > >(tee /home/ubuntu/user-data.log) 2>&1

echo "=================================================="
echo "BPAY ETL DATABASE INITIALIZATION"
echo "=================================================="

#############################################
# UPDATE
#############################################

apt-get update -y

#############################################
# MYSQL CLIENT
#############################################

apt-get install -y mysql-client \
|| apt-get install -y default-mysql-client

#############################################
# WAIT FOR RDS
#############################################

echo "Waiting for RDS..."

until mysql \
-h "${rds_host}" \
-u "${db_user}" \
-p"${db_password}" \
-e "SELECT 1" >/dev/null 2>&1
do
    echo "Waiting..."
    sleep 10
done

echo "RDS Ready"

#############################################
# CREATE SQL FILES
#############################################

echo "${source_sql_b64}" | base64 -d > /home/ubuntu/init-source.sql

echo "${replicated_sql_b64}" | base64 -d > /home/ubuntu/init-replicated.sql

echo "${unified_sql_b64}" | base64 -d > /home/ubuntu/init-unified.sql

chmod 600 /home/ubuntu/init-*.sql

#############################################
# EXECUTE SOURCE
#############################################

echo "Initializing SOURCE database..."

mysql \
-h "${rds_host}" \
-u "${db_user}" \
-p"${db_password}" \
< /home/ubuntu/init-source.sql

#############################################
# EXECUTE REPLICATED
#############################################

echo "Initializing REPLICATED database..."

mysql \
-h "${rds_host}" \
-u "${db_user}" \
-p"${db_password}" \
< /home/ubuntu/init-replicated.sql

#############################################
# EXECUTE UNIFIED
#############################################

echo "Initializing UNIFIED database..."

mysql \
-h "${rds_host}" \
-u "${db_user}" \
-p"${db_password}" \
< /home/ubuntu/init-unified.sql

#############################################
# VERIFY SOURCE
#############################################

echo "Verifying SOURCE..."

mysql \
-h "${rds_host}" \
-u "${db_user}" \
-p"${db_password}" <<EOF

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

#############################################
# VERIFY DATABASES
#############################################

mysql \
-h "${rds_host}" \
-u "${db_user}" \
-p"${db_password}" \
-e "SHOW DATABASES;"

echo "=================================================="
echo "DATABASE INITIALIZATION COMPLETED"
echo "=================================================="