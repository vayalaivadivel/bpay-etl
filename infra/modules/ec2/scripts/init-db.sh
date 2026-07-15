#!/bin/bash

set -euo pipefail

#############################################
# LOAD COMMON FUNCTIONS
#############################################

source /opt/bpay/scripts/common.sh

#############################################
# WAIT FOR RDS
#############################################

wait_for_rds

#############################################
# INITIALIZE DATABASES
#############################################

run_sql /opt/bpay/sql/init-databases.sql

#############################################
# INITIALIZE SOURCE DATABASE
#############################################

run_sql /opt/bpay/sql/init-source.sql

#############################################
# INITIALIZE REPLICATED DATABASE
#############################################

run_sql /opt/bpay/sql/init-replicated.sql

#############################################
# INITIALIZE UNIFIED DATABASE
#############################################

run_sql /opt/bpay/sql/init-unified.sql

echo
echo "========================================"
echo "Database initialization completed."
echo "========================================"