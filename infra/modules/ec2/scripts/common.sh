#!/bin/bash

set -euo pipefail

#############################################
# WAIT FOR RDS
#############################################

wait_for_rds() {

    echo
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
# EXECUTE SQL
#############################################

run_sql() {

    local FILE="$1"

    echo
    echo "========================================"
    echo "Executing : ${FILE}"
    echo "========================================"

    mysql \
        -vvv \
        -h "${RDS_HOST}" \
        -u "${DB_USER}" \
        -p"${DB_PASSWORD}" \
        < "${FILE}"

    local RC=$?

    echo "Exit Code : ${RC}"

    if [ ${RC} -ne 0 ]; then
        echo "FAILED : ${FILE}"
        exit ${RC}
    fi

    echo "SUCCESS : ${FILE}"
}

#############################################
# VERIFY DATABASE
#############################################

verify_database() {

    echo
    echo "========================================"
    echo "Verifying ${DB_NAME}"
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

    echo
    echo "========================================"
    echo "Database verification successful."
    echo "========================================"
}