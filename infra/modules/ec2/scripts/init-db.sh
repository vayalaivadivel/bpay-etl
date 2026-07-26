#!/bin/bash

set -euo pipefail

source /opt/bpay/scripts/common.sh

echo
echo "========================================"
echo "BPAY Database Initialization"
echo "========================================"

echo "RDS_HOST : ${RDS_HOST}"
echo "DB_USER  : ${DB_USER}"
echo "DB_NAME  : ${DB_NAME}"

wait_for_rds

run_sql /opt/bpay/sql/init-databases.sql
run_sql /opt/bpay/sql/init-source.sql
run_sql /opt/bpay/sql/init-replicated.sql
run_sql /opt/bpay/sql/init-unified.sql

echo
echo "========================================"
echo "Database initialization completed."
echo "========================================"