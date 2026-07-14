#!/bin/bash

set -euo pipefail

echo "=========================================="
echo "VERIFYING BPAY DATABASES"
echo "=========================================="

mysql \
-h "${RDS_HOST}" \
-u "${DB_USER}" \
-p"${DB_PASSWORD}" <<EOF

SHOW DATABASES;

USE ${DB_NAME};

SELECT 'cardholders', COUNT(*) FROM cardholders
UNION ALL
SELECT 'cards', COUNT(*) FROM cards
UNION ALL
SELECT 'merchant_categories', COUNT(*) FROM merchant_categories
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'offers', COUNT(*) FROM offers
UNION ALL
SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL
SELECT 'reward_points', COUNT(*) FROM reward_points;

USE ${REPLICATED_DB_NAME};

SHOW TABLES;

USE ${UNIFIED_DB_NAME};

SHOW TABLES;

EOF

echo
echo "=========================================="
echo "DATABASE VERIFICATION COMPLETED"
echo "=========================================="