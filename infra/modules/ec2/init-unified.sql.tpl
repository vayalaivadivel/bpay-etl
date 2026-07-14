-- =============================================================================
-- BPAY ETL - UNIFIED DATABASE INITIALIZATION
-- =============================================================================

CREATE DATABASE IF NOT EXISTS ${unified_db_name};

USE ${unified_db_name};

-- =============================================================================
-- 1. CARDHOLDERS
-- =============================================================================

CREATE TABLE IF NOT EXISTS cardholders (

    cardholder_id INT PRIMARY KEY,

    customer_name VARCHAR(100),

    email VARCHAR(100),

    mobile VARCHAR(20),

    city VARCHAR(50),

    state VARCHAR(50),

    loyalty_tier VARCHAR(20),

    created_date TIMESTAMP NULL

);

-- =============================================================================
-- 2. CARDS
-- =============================================================================

CREATE TABLE IF NOT EXISTS cards (

    card_id INT PRIMARY KEY,

    cardholder_id INT NOT NULL,

    card_number VARCHAR(20),

    card_type VARCHAR(30),

    issuer VARCHAR(50),

    credit_limit DECIMAL(12,2),

    card_status VARCHAR(20),

    issue_date DATE,

    CONSTRAINT fk_unified_cards_cardholder
        FOREIGN KEY (cardholder_id)
        REFERENCES cardholders(cardholder_id)

);

-- =============================================================================
-- 3. MERCHANT CATEGORIES
-- =============================================================================

CREATE TABLE IF NOT EXISTS merchant_categories (

    category_id INT PRIMARY KEY,

    category_name VARCHAR(100),

    reward_multiplier DECIMAL(5,2)

);

-- =============================================================================
-- 4. CAMPAIGNS
-- =============================================================================

CREATE TABLE IF NOT EXISTS campaigns (

    campaign_id INT PRIMARY KEY,

    campaign_name VARCHAR(100),

    campaign_type VARCHAR(50),

    start_date DATE,

    end_date DATE,

    campaign_status VARCHAR(20)

);

-- =============================================================================
-- 5. OFFERS
-- =============================================================================

CREATE TABLE IF NOT EXISTS offers (

    offer_id INT PRIMARY KEY,

    merchant_name VARCHAR(100),

    offer_name VARCHAR(100),

    cashback_percent DECIMAL(5,2),

    minimum_spend DECIMAL(12,2),

    start_date DATE,

    end_date DATE,

    offer_status VARCHAR(20)

);

-- =============================================================================
-- 6. TRANSACTIONS
-- =============================================================================

CREATE TABLE IF NOT EXISTS transactions (

    transaction_id INT PRIMARY KEY,

    card_id INT NOT NULL,

    category_id INT NOT NULL,

    merchant_name VARCHAR(100),

    transaction_amount DECIMAL(12,2),

    currency VARCHAR(10),

    transaction_date DATE,

    transaction_status VARCHAR(20),

    CONSTRAINT fk_unified_transactions_card
        FOREIGN KEY (card_id)
        REFERENCES cards(card_id),

    CONSTRAINT fk_unified_transactions_category
        FOREIGN KEY (category_id)
        REFERENCES merchant_categories(category_id)

);

-- =============================================================================
-- 7. REWARD POINTS
-- =============================================================================

CREATE TABLE IF NOT EXISTS reward_points (

    reward_id INT PRIMARY KEY,

    transaction_id INT NOT NULL,

    earned_points INT,

    redeemed_points INT,

    available_points INT,

    processed_date DATE,

    CONSTRAINT fk_unified_reward_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions(transaction_id)

);

-- =============================================================================
-- END OF UNIFIED DATABASE
-- =============================================================================