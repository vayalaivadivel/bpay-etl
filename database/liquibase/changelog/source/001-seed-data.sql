--liquibase formatted sql

--changeset vadivel:001-seed-cardholders
INSERT INTO cardholders
(cardholder_id, customer_name, email, mobile, city, state, loyalty_tier, created_date)
VALUES
(101,'Rahul Sharma','rahul@gmail.com','9876500001','Hyderabad','Telangana','Gold',NOW()),
(102,'Priya Nair','priya@gmail.com','9876500002','Bengaluru','Karnataka','Silver',NOW()),
(103,'Arun Kumar','arun@gmail.com','9876500003','Chennai','Tamil Nadu','Platinum',NOW()),
(104,'Sneha Rao','sneha@gmail.com','9876500004','Mumbai','Maharashtra','Gold',NOW()),
(105,'Vikram Singh','vikram@gmail.com','9876500005','Delhi','Delhi','Silver',NOW());

--changeset vadivel:002-seed-cards
INSERT INTO cards
(card_id, cardholder_id, card_number, card_type, issuer, credit_limit, card_status, issue_date)
VALUES
(1001,101,'4111111111111111','Visa','HDFC',500000,'ACTIVE','2024-01-10'),
(1002,102,'5555555555554444','Mastercard','ICICI',300000,'ACTIVE','2024-02-12'),
(1003,103,'378282246310005','Amex','Amex',800000,'ACTIVE','2024-03-01'),
(1004,104,'4000000000000002','Visa','SBI',400000,'ACTIVE','2024-01-25'),
(1005,105,'6011111111111117','RuPay','Axis',250000,'ACTIVE','2024-02-15');

--changeset vadivel:003-seed-merchant-categories
INSERT INTO merchant_categories
(category_id, category_name, reward_multiplier)
VALUES
(1,'Fuel',2.00),
(2,'Grocery',3.00),
(3,'Dining',5.00),
(4,'Travel',10.00),
(5,'Shopping',4.00);

--changeset vadivel:004-seed-offers
INSERT INTO offers
(offer_id, merchant_name, offer_name, cashback_percent, minimum_spend, start_date, end_date, offer_status)
VALUES
(1,'Amazon','10% Cashback',10,5000,'2026-06-01','2026-12-31','ACTIVE'),
(2,'DMart','5% Cashback',5,3000,'2026-06-01','2026-12-31','ACTIVE'),
(3,'Indian Oil','2X Reward Points',2,1000,'2026-06-01','2026-12-31','ACTIVE');

--changeset vadivel:005-seed-campaigns
INSERT INTO campaigns
(campaign_id, campaign_name, campaign_type, start_date, end_date, campaign_status)
VALUES
(1,'Summer Rewards','Cashback','2026-06-01','2026-08-31','ACTIVE'),
(2,'Travel Bonanza','Travel','2026-06-01','2026-09-30','ACTIVE');

--changeset vadivel:006-seed-transactions
INSERT INTO transactions
(transaction_id, card_id, category_id, offer_id, campaign_id, merchant_name, transaction_amount, currency, transaction_date, transaction_status)
VALUES
(5001,1001,1,3,1,'Indian Oil',2500,'INR','2026-06-01','SUCCESS'),
(5002,1002,2,2,1,'DMart',5200,'INR','2026-06-02','SUCCESS'),
(5003,1003,4,NULL,2,'IndiGo',18500,'INR','2026-06-03','SUCCESS'),
(5004,1004,3,NULL,NULL,'Barbeque Nation',3200,'INR','2026-06-04','SUCCESS'),
(5005,1005,5,1,NULL,'Amazon',7600,'INR','2026-06-05','SUCCESS');

--changeset vadivel:007-seed-reward-points
INSERT INTO reward_points
(reward_id, transaction_id, earned_points, redeemed_points, available_points, processed_date)
VALUES
(9001,5001,50,0,50,'2026-06-01'),
(9002,5002,150,0,150,'2026-06-02'),
(9003,5003,925,0,925,'2026-06-03'),
(9004,5004,160,0,160,'2026-06-04'),
(9005,5005,304,0,304,'2026-06-05');

--changeset susmita:008-seed-employees
CREATE TABLE emp (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

--changeset susmita:008-seed-employees-insert
INSERT INTO emp (emp_id, emp_name, department, salary)
VALUES (1, 'Vadivel', 'IT', 75000.00);
