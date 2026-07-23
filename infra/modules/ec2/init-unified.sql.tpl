-- =============================================================================
-- BPAY ETL - UNIFIED DATA WAREHOUSE INITIALIZATION
-- Gold Layer (Star Schema)
-- =============================================================================

USE ${unified_db_name};

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- DIMENSION : CUSTOMER
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_customer (

    customer_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    cardholder_id INT NOT NULL,

    customer_name VARCHAR(100),

    email VARCHAR(100),

    mobile VARCHAR(20),

    city VARCHAR(50),

    state VARCHAR(50),

    loyalty_tier VARCHAR(20),

    created_date TIMESTAMP,

    effective_from DATETIME DEFAULT CURRENT_TIMESTAMP,

    effective_to DATETIME DEFAULT '9999-12-31 23:59:59',

    current_flag CHAR(1) DEFAULT 'Y',

    UNIQUE(cardholder_id)

);

-- =============================================================================
-- DIMENSION : CARD
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_card (

    card_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    card_id INT NOT NULL,

    customer_key BIGINT NOT NULL,

    card_number VARCHAR(20),

    card_type VARCHAR(30),

    issuer VARCHAR(50),

    credit_limit DECIMAL(12,2),

    card_status VARCHAR(20),

    issue_date DATE,

    UNIQUE(card_id),

    CONSTRAINT fk_dim_card_customer
        FOREIGN KEY(customer_key)
        REFERENCES dim_customer(customer_key)

);

-- =============================================================================
-- DIMENSION : MERCHANT
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_merchant (

    merchant_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    merchant_name VARCHAR(100),

    category_id INT,

    category_name VARCHAR(100),

    reward_multiplier DECIMAL(5,2),

    UNIQUE(merchant_name)

);

-- =============================================================================
-- DIMENSION : OFFER
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_offer (

    offer_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    offer_id INT NOT NULL,

    merchant_name VARCHAR(100),

    offer_name VARCHAR(100),

    cashback_percent DECIMAL(5,2),

    minimum_spend DECIMAL(12,2),

    start_date DATE,

    end_date DATE,

    offer_status VARCHAR(20),

    UNIQUE(offer_id)

);

-- =============================================================================
-- DIMENSION : CAMPAIGN
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_campaign (

    campaign_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    campaign_id INT NOT NULL,

    campaign_name VARCHAR(100),

    campaign_type VARCHAR(50),

    start_date DATE,

    end_date DATE,

    campaign_status VARCHAR(20),

    UNIQUE(campaign_id)

);

-- =============================================================================
-- DIMENSION : DATE
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_date (

    date_key INT PRIMARY KEY,

    full_date DATE,

    day_number INT,

    month_number INT,

    month_name VARCHAR(20),

    quarter_number INT,

    year_number INT,

    weekday_name VARCHAR(20),

    weekend_flag CHAR(1)

);

-- =============================================================================
-- FACT : REWARD TRANSACTION
-- =============================================================================

CREATE TABLE IF NOT EXISTS fact_reward_transaction (

    reward_transaction_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    transaction_id INT,

    date_key INT,

    customer_key BIGINT,

    card_key BIGINT,

    merchant_key BIGINT,

    offer_key BIGINT NULL,

    campaign_key BIGINT NULL,

    transaction_amount DECIMAL(12,2),

    currency VARCHAR(10),

    earned_points INT,

    redeemed_points INT,

    available_points INT,

    transaction_status VARCHAR(20),

    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fact_date
        FOREIGN KEY(date_key)
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY(customer_key)
        REFERENCES dim_customer(customer_key),

    CONSTRAINT fk_fact_card
        FOREIGN KEY(card_key)
        REFERENCES dim_card(card_key),

    CONSTRAINT fk_fact_merchant
        FOREIGN KEY(merchant_key)
        REFERENCES dim_merchant(merchant_key),

    CONSTRAINT fk_fact_offer
        FOREIGN KEY(offer_key)
        REFERENCES dim_offer(offer_key),

    CONSTRAINT fk_fact_campaign
        FOREIGN KEY(campaign_key)
        REFERENCES dim_campaign(campaign_key)

);

-- =============================================================================
-- FACT : CUSTOMER REWARD BALANCE
-- =============================================================================

CREATE TABLE IF NOT EXISTS fact_reward_balance (

    balance_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    customer_key BIGINT,

    date_key INT,

    earned_points INT,

    redeemed_points INT,

    available_points INT,

    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_balance_customer
        FOREIGN KEY(customer_key)
        REFERENCES dim_customer(customer_key),

    CONSTRAINT fk_balance_date
        FOREIGN KEY(date_key)
        REFERENCES dim_date(date_key)

);

-- =============================================================================
-- FACT : CAMPAIGN PERFORMANCE
-- =============================================================================

CREATE TABLE IF NOT EXISTS fact_campaign_performance (

    performance_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    campaign_key BIGINT,

    date_key INT,

    transaction_count INT,

    total_sales DECIMAL(12,2),

    reward_points INT,

    participating_customers INT,

    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_campaign_perf_campaign
        FOREIGN KEY(campaign_key)
        REFERENCES dim_campaign(campaign_key),

    CONSTRAINT fk_campaign_perf_date
        FOREIGN KEY(date_key)
        REFERENCES dim_date(date_key)

);

SET FOREIGN_KEY_CHECKS = 1;