CREATE TABLE IF NOT EXISTS offer (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    credit_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    offer_name VARCHAR(255) NOT NULL,
    offer_type VARCHAR(50),
    amount DECIMAL(12,2),
    currency VARCHAR(10) DEFAULT 'INR',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    start_date DATETIME,
    end_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO offer 
(credit_id, account_id, offer_name, offer_type, amount, status, start_date, end_date)
VALUES
(1001, 501, 'Festival Cashback', 'CASHBACK', 500.00, 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 10 DAY)),
(1002, 502, 'Loan Offer', 'LOAN', 10000.00, 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),
(1001, 501, 'Shopping Discount', 'DISCOUNT', 200.00, 'EXPIRED', NOW(), DATE_SUB(NOW(), INTERVAL 1 DAY));

CREATE DATABASE IF NOT EXISTS rldb_raw_dev;

CREATE DATABASE IF NOT EXISTS rldb_replicated_dev;

CREATE DATABASE IF NOT EXISTS rldb_unified_dev; 

# AIRFLOW DATABASE 
CREATE DATABASE IF NOT EXISTS airflow;

# HOP Database
CREATE DATABASE IF NOT EXISTS hop;