#!/bin/bash

set -euo pipefail

#########################################
# LOGGING
#########################################

exec > >(tee /home/ubuntu/user-data.log) 2>&1

echo "=================================================="
echo "BPAY ETL DATABASE INITIALIZATION"
echo "=================================================="

#########################################
# UPDATE SYSTEM
#########################################

echo "Updating packages..."

apt-get update -y

#########################################
# INSTALL MYSQL CLIENT
#########################################

echo "Installing MySQL Client..."

apt-get install -y mysql-client \
|| apt-get install -y default-mysql-client \
|| apt-get install -y mysql-client-core-8.0

if ! command -v mysql >/dev/null 2>&1; then
    echo "ERROR: MySQL client installation failed."
    exit 1
fi

echo "MySQL Client Installed Successfully"

mysql --version

#########################################
# WAIT FOR RDS
#########################################

echo "Waiting for RDS..."

RETRIES=30
COUNT=0

until mysql \
    -h "${rds_host}" \
    -u "${db_user}" \
    -p"${db_password}" \
    -e "SELECT 1" >/dev/null 2>&1
do
    COUNT=$((COUNT+1))

    echo "Attempt $${COUNT}/$${RETRIES}..."

    if [ $${COUNT} -ge $${RETRIES} ]; then
        echo "ERROR: Unable to connect to RDS."
        exit 1
    fi

    sleep 10
done

echo "RDS is Ready."

#########################################
# SQL EXECUTION FUNCTION
#########################################

run_sql() {

    FILE=$1

    echo "=================================================="
    echo "Executing: $${FILE}"
    echo "=================================================="

    mysql \
        -h "${rds_host}" \
        -u "${db_user}" \
        -p"${db_password}" \
        < "$${FILE}"

    RC=$?

    if [ $${RC} -ne 0 ]; then
        echo "ERROR: Failed executing $${FILE}"
        exit $${RC}
    fi

    echo "SUCCESS: $${FILE}"
    echo "Completed at $(date)"
    echo
}

#########################################
# CREATE SQL FILES
#########################################

echo "Creating SQL files..."

echo "${database_sql_b64}" | base64 -d > /home/ubuntu/init-databases.sql
echo "${source_sql_b64}" | base64 -d > /home/ubuntu/init-source.sql
echo "${replicated_sql_b64}" | base64 -d > /home/ubuntu/init-replicated.sql
echo "${unified_sql_b64}" | base64 -d > /home/ubuntu/init-unified.sql

chmod 600 /home/ubuntu/init-*.sql

echo "SQL files created successfully."

#########################################
# EXECUTE SQL FILES
#########################################

run_sql /home/ubuntu/init-databases.sql

run_sql /home/ubuntu/init-source.sql

run_sql /home/ubuntu/init-replicated.sql

run_sql /home/ubuntu/init-unified.sql

#########################################
# VERIFY SOURCE DATABASE
#########################################

echo "=================================================="
echo "Verifying Source Database"
echo "=================================================="

mysql \
    -h "${rds_host}" \
    -u "${db_user}" \
    -p"${db_password}" <<EOF

USE ${db_name};

SELECT 'cardholders', COUNT(*) FROM cardholders
UNION ALL
SELECT 'cards', COUNT(*) FROM cards
UNION ALL
SELECT 'merchant_categories', COUNT(*) FROM merchant_categories
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'offers', COUNT(*) FROM offers
UNION ALL
SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL
SELECT 'reward_points', COUNT(*) FROM reward_points;

EOF


#########################################
# VERIFY REPLICATED DATABASE
#########################################

echo
echo "=================================================="
echo "Verifying Replicated Database"
echo "=================================================="

mysql \
    -h "${rds_host}" \
    -u "${db_user}" \
    -p"${db_password}" <<EOF

USE ${replicated_db_name};

SHOW TABLES;

EOF

#########################################
# VERIFY UNIFIED DATABASE
#########################################

echo
echo "=================================================="
echo "Verifying Unified Database"
echo "=================================================="

mysql \
    -h "${rds_host}" \
    -u "${db_user}" \
    -p"${db_password}" <<EOF

USE ${unified_db_name};

SHOW TABLES;

EOF

#########################################
# VERIFY DATABASES
#########################################

echo
echo "Available Databases"

mysql \
    -h "${rds_host}" \
    -u "${db_user}" \
    -p"${db_password}" \
    -e "SHOW DATABASES;"

echo
echo "=================================================="
echo "DATABASE INITIALIZATION COMPLETED SUCCESSFULLY"
echo "=================================================="