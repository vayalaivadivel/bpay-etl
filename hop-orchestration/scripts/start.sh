#!/bin/sh

set -e

echo "Starting Health Server..."

while true; do
    printf "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 2\r\n\r\nOK" \
    | nc -l -p 8081
done &

echo "Starting Apache Hop..."

exec /bin/bash /opt/hop/run.sh