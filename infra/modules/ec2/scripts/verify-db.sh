#!/bin/bash

set -euo pipefail

source /opt/bpay/scripts/common.sh

echo
echo "========================================"
echo "Verifying Source Database"
echo "========================================"

verify_database

echo
echo "========================================"
echo "Database verification completed."
echo "========================================"