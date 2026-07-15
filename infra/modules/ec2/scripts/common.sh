#!/bin/bash

set -euo pipefail

#############################################
# LOAD CONFIGURATION
#############################################

#source /home/ubuntu/bpay.env

#############################################
# WAIT FOR RDS
#############################################

wait_for_rds() {

    echo "========================================"
    echo "Waiting for RDS..."
    echo "========================================"

    until mysql \
        -h "${RDS_HOST}" \
        -u "${DB_USER}" \
        -p"${DB_PASSWORD}" \
        -e "SELECT 1" >/dev/null 2>&1
    do
        echo "RDS not ready. Retrying in 10 seconds..."
        sleep 10
    done

    echo "RDS is ready."
}

#############################################
# EXECUTE SQL FILE
#############################################

run_sql() {

    local FILE=$1

    echo
    echo "========================================"
    echo "Executing SQL : ${FILE}"
    echo "========================================"

    mysql \
        -h "${RDS_HOST}" \
        -u "${DB_USER}" \
        -p"${DB_PASSWORD}" \
        < "${FILE}"

    RC=$?

    if [ $RC -ne 0 ]; then
        echo "ERROR : Failed executing ${FILE}"
        exit $RC
    fi

    echo "SUCCESS : ${FILE}"
}

#############################################
# VERIFY DATABASE
#############################################

verify_database() {

    echo
    echo "========================================"
    echo "Verifying database..."
    echo "========================================"

    mysql \
        -h "${RDS_HOST}" \
        -u "${DB_USER}" \
        -p"${DB_PASSWORD}" <<EOF

USE ${DB_NAME};

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

    RC=$?

    if [ $RC -ne 0 ]; then
        echo "ERROR : Database verification failed."
        exit $RC
    fi

    echo
    echo "========================================"
    echo "Database verification successful."
    echo "========================================"
}