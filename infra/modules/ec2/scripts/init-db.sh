#!/bin/bash

set -euo pipefail

source /opt/bpay/scripts/common.sh

wait_for_rds

run_sql /opt/bpay/sql/init-databases.sql

run_sql /opt/bpay/sql/init-source.sql

run_sql /opt/bpay/sql/init-replicated.sql

run_sql /opt/bpay/sql/init-unified.sql

echo "Database initialization completed."