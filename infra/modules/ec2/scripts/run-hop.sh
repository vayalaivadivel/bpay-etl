#!/bin/bash

set -euo pipefail

HOP_HOME=/opt/hop

PROJECT_HOME=/opt/bpay/hop

PIPELINE=$1

echo "Running Hop Workflow..."

${HOP_HOME}/hop-run.sh \
    --project=card-rewards-etl \
    --file=${PROJECT_HOME}/${PIPELINE}

echo "Workflow completed."