#!/bin/bash

set -euo pipefail

#############################################
# LOAD COMMON FUNCTIONS
#############################################

source /home/ubuntu/scripts/common.sh

#############################################
# WAIT FOR RDS
#############################################

wait_for_rds

#############################################
# INITIALIZE DATABASES
#############################################

run_sql /home/ubuntu/init-databases.sql

#############################################
# INITIALIZE SOURCE DATABASE
#############################################

run_sql /home/ubuntu/init-source.sql

#############################################
# INITIALIZE REPLICATED DATABASE
#############################################

run_sql /home/ubuntu/init-replicated.sql

#############################################
# INITIALIZE UNIFIED DATABASE
#############################################

run_sql /home/ubuntu/init-unified.sql

#############################################
# COMPLETED
#############################################

echo
echo "========================================"
echo "Database initialization completed."
echo "========================================"