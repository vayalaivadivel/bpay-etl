#!/usr/bin/env bash
set -e

echo "Starting Airflow initialization..."

# Initialize or migrate metadata database
airflow db migrate

# Create Airflow admin user
airflow users create \
    --username vadivel \
    --password vadivel \
    --firstname Vadivel \
    --lastname PM \
    --role Admin \
    --email vayalaivadivel@gmail.com || true

echo "Starting Airflow scheduler..."

# Start scheduler in background; logs go to container stdout/stderr
airflow scheduler &

echo "Starting Airflow webserver..."

# Keep webserver in foreground
exec airflow webserver