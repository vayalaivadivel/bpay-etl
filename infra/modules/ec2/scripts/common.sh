#!/bin/bash

set -euo pipefail

wait_for_rds() {

    echo "Waiting for RDS..."

    RETRIES=30
    COUNT=0

    until mysql \
        -h "${RDS_HOST}" \
        -u "${DB_USER}" \
        -p"${DB_PASSWORD}" \
        -e "SELECT 1" >/dev/null 2>&1
    do

        COUNT=$((COUNT+1))

        echo "Attempt ${COUNT}/${RETRIES}"

        if [ $COUNT -ge $RETRIES ]; then
            echo "RDS not available."
            exit 1
        fi

        sleep 10
    done

    echo "RDS Ready."
}

run_sql() {

    FILE=$1

    echo "Executing ${FILE}"

    mysql \
        -h "${RDS_HOST}" \
        -u "${DB_USER}" \
        -p"${DB_PASSWORD}" \
        < "${FILE}"

    echo "Completed ${FILE}"
}