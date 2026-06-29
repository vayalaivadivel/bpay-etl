-- Create Schema
CREATE DATABASE IF NOT EXISTS ${raw_db_name};
CREATE DATABASE IF NOT EXISTS ${replicated_db_name};
CREATE DATABASE IF NOT EXISTS ${unified_db_name};

CREATE DATABASE IF NOT EXISTS airflow;
CREATE DATABASE IF NOT EXISTS hop;

CREATE DATABASE IF NOT EXISTS ${db_name};
USE ${db_name};

-- =====================================================
-- CREATE DATABASES
-- =====================================================

CREATE DATABASE IF NOT EXISTS ${raw_db_name};
CREATE DATABASE IF NOT EXISTS ${replicated_db_name};
CREATE DATABASE IF NOT EXISTS ${unified_db_name};

CREATE DATABASE IF NOT EXISTS airflow;
CREATE DATABASE IF NOT EXISTS hop;

CREATE DATABASE IF NOT EXISTS ${db_name};

USE ${db_name};

-- =====================================================
-- 1. CARDHOLDERS
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.cardholders (

    cardholder_id INT PRIMARY KEY,

    customer_name VARCHAR(100),

    email VARCHAR(100),

    mobile VARCHAR(20),

    city VARCHAR(50),

    state VARCHAR(50),

    loyalty_tier VARCHAR(20),

    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. CARDS
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.cards (

    card_id INT PRIMARY KEY,

    cardholder_id INT,

    card_number VARCHAR(20),

    card_type VARCHAR(30),

    issuer VARCHAR(50),

    credit_limit DECIMAL(12,2),

    card_status VARCHAR(20),

    issue_date DATE,

    FOREIGN KEY (cardholder_id)
        REFERENCES ${db_name}.cardholders(cardholder_id)
);

-- =====================================================
-- 3. MERCHANT CATEGORIES
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.merchant_categories (

    category_id INT PRIMARY KEY,

    category_name VARCHAR(100),

    reward_multiplier DECIMAL(5,2)
);

-- =====================================================
-- 4. TRANSACTIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.transactions (

    transaction_id INT PRIMARY KEY,

    card_id INT,

    category_id INT,

    merchant_name VARCHAR(100),

    transaction_amount DECIMAL(12,2),

    currency VARCHAR(10),

    transaction_date DATE,

    transaction_status VARCHAR(20),

    FOREIGN KEY (card_id)
        REFERENCES ${db_name}.cards(card_id),

    FOREIGN KEY (category_id)
        REFERENCES ${db_name}.merchant_categories(category_id)
);

-- =====================================================
-- 5. OFFERS
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.offers (

    offer_id INT PRIMARY KEY,

    merchant_name VARCHAR(100),

    offer_name VARCHAR(100),

    cashback_percent DECIMAL(5,2),

    minimum_spend DECIMAL(12,2),

    start_date DATE,

    end_date DATE,

    offer_status VARCHAR(20)
);

-- =====================================================
-- 6. CAMPAIGNS
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.campaigns (

    campaign_id INT PRIMARY KEY,

    campaign_name VARCHAR(100),

    campaign_type VARCHAR(50),

    start_date DATE,

    end_date DATE,

    campaign_status VARCHAR(20)
);

-- =====================================================
-- 7. REWARD POINTS
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.reward_points (

    reward_id INT PRIMARY KEY,

    transaction_id INT,

    earned_points INT,

    redeemed_points INT,

    available_points INT,

    processed_date DATE,

    FOREIGN KEY (transaction_id)
        REFERENCES ${db_name}.transactions(transaction_id)
);

-- =====================================================
-- INSERT CARDHOLDERS
-- =====================================================

INSERT INTO ${db_name}.cardholders
VALUES
(101,'Rahul Sharma','rahul@gmail.com','9876500001','Hyderabad','Telangana','Gold',NOW()),
(102,'Priya Nair','priya@gmail.com','9876500002','Bengaluru','Karnataka','Silver',NOW()),
(103,'Arun Kumar','arun@gmail.com','9876500003','Chennai','Tamil Nadu','Platinum',NOW()),
(104,'Sneha Rao','sneha@gmail.com','9876500004','Mumbai','Maharashtra','Gold',NOW()),
(105,'Vikram Singh','vikram@gmail.com','9876500005','Delhi','Delhi','Silver',NOW());

-- =====================================================
-- INSERT CARDS
-- =====================================================

INSERT INTO ${db_name}.cards
VALUES
(1001,101,'4111111111111111','Visa','HDFC',500000,'ACTIVE','2024-01-10'),
(1002,102,'5555555555554444','Mastercard','ICICI',300000,'ACTIVE','2024-02-12'),
(1003,103,'378282246310005','Amex','Amex',800000,'ACTIVE','2024-03-01'),
(1004,104,'4000000000000002','Visa','SBI',400000,'ACTIVE','2024-01-25'),
(1005,105,'6011111111111117','RuPay','Axis',250000,'ACTIVE','2024-02-15');

-- =====================================================
-- INSERT MERCHANT CATEGORIES
-- =====================================================

INSERT INTO ${db_name}.merchant_categories
VALUES
(1,'Fuel',2.0),
(2,'Grocery',3.0),
(3,'Dining',5.0),
(4,'Travel',10.0),
(5,'Shopping',4.0);

-- =====================================================
-- INSERT TRANSACTIONS
-- =====================================================

INSERT INTO ${db_name}.transactions
VALUES
(5001,1001,1,'Indian Oil',2500,'INR','2026-06-01','SUCCESS'),
(5002,1002,2,'DMart',5200,'INR','2026-06-02','SUCCESS'),
(5003,1003,4,'IndiGo',18500,'INR','2026-06-03','SUCCESS'),
(5004,1004,3,'Barbeque Nation',3200,'INR','2026-06-04','SUCCESS'),
(5005,1005,5,'Amazon',7600,'INR','2026-06-05','SUCCESS');

-- =====================================================
-- INSERT OFFERS
-- =====================================================

INSERT INTO ${db_name}.offers
VALUES
(1,'Amazon','10% Cashback',10,5000,'2026-06-01','2026-12-31','ACTIVE'),
(2,'DMart','5% Cashback',3000,'2026-06-01','2026-12-31','ACTIVE'),
(3,'Indian Oil','2X Reward Points',1000,'2026-06-01','2026-12-31','ACTIVE');

-- =====================================================
-- INSERT CAMPAIGNS
-- =====================================================

INSERT INTO ${db_name}.campaigns
VALUES
(1,'Summer Rewards','Cashback','2026-06-01','2026-08-31','ACTIVE'),
(2,'Travel Bonanza','Travel','2026-06-01','2026-09-30','ACTIVE');

-- =====================================================
-- INSERT REWARD POINTS
-- =====================================================

INSERT INTO ${db_name}.reward_points
VALUES
(9001,5001,50,0,50,'2026-06-01'),
(9002,5002,150,0,150,'2026-06-02'),
(9003,5003,925,0,925,'2026-06-03'),
(9004,5004,160,0,160,'2026-06-04'),
(9005,5005,304,0,304,'2026-06-05');