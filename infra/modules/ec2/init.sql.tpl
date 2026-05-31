-- Create Schema
CREATE SCHEMA IF NOT EXISTS ${db_name};

-- =====================================================
-- 1. Patients Table
-- =====================================================

CREATE TABLE IF NOT EXISTS bpaydb.patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    phone_number VARCHAR(20),
    city VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. Billing Table
-- =====================================================

CREATE TABLE IF NOT EXISTS  ${db_name}.billing (
    bill_id INT PRIMARY KEY,
    patient_id INT,
    treatment_type VARCHAR(100),
    doctor_name VARCHAR(100),
    bill_date DATE,
    bill_amount DECIMAL(12,2),
    bill_status VARCHAR(20),
    FOREIGN KEY (patient_id)
        REFERENCES  ${db_name}.patients(patient_id)
);

-- =====================================================
-- 3. Payments Table
-- =====================================================

CREATE TABLE IF NOT EXISTS ${db_name}.payments (
    payment_id INT PRIMARY KEY,
    bill_id INT,
    payment_date DATE,
    payment_mode VARCHAR(30),
    paid_amount DECIMAL(12,2),
    transaction_status VARCHAR(20),
    FOREIGN KEY (bill_id)
        REFERENCES  ${db_name}.billing(bill_id)
);

-- =====================================================
-- Insert Patients
-- =====================================================

INSERT INTO  ${db_name}.patients
(patient_id, patient_name, gender, age, phone_number, city)
VALUES
(101, 'Ravi Kumar', 'Male', 35, '9876543210', 'Hyderabad'),
(102, 'Sita Devi', 'Female', 29, '9876543211', 'Vijayawada'),
(103, 'Arjun Rao', 'Male', 45, '9876543212', 'Visakhapatnam'),
(104, 'Priya Sharma', 'Female', 31, '9876543213', 'Guntur'),
(105, 'Rahul Verma', 'Male', 52, '9876543214', 'Warangal');

-- =====================================================
-- Insert Billing Records
-- =====================================================

INSERT INTO  ${db_name}.billing
(bill_id, patient_id, treatment_type, doctor_name,
 bill_date, bill_amount, bill_status)
VALUES
(1001, 101, 'General Checkup', 'Dr. Reddy',
 '2026-05-01', 1500.00, 'PAID'),

(1002, 102, 'Blood Test', 'Dr. Kumar',
 '2026-05-02', 2500.00, 'PAID'),

(1003, 103, 'MRI Scan', 'Dr. Sharma',
 '2026-05-03', 12000.00, 'PENDING'),

(1004, 104, 'Surgery', 'Dr. Naidu',
 '2026-05-04', 55000.00, 'PARTIAL'),

(1005, 105, 'X-Ray', 'Dr. Rao',
 '2026-05-05', 3000.00, 'PAID');

-- =====================================================
-- Insert Payments
-- =====================================================

INSERT INTO  ${db_name}.payments
(payment_id, bill_id, payment_date,
 payment_mode, paid_amount, transaction_status)
VALUES
(5001, 1001, '2026-05-01', 'UPI', 1500.00, 'SUCCESS'),

(5002, 1002, '2026-05-02', 'CARD', 2500.00, 'SUCCESS'),

(5003, 1004, '2026-05-04', 'NETBANKING', 25000.00, 'SUCCESS'),

(5004, 1005, '2026-05-05', 'CASH', 3000.00, 'SUCCESS');


CREATE DATABASE IF NOT EXISTS ${raw_db_name};

CREATE DATABASE IF NOT EXISTS ${replicated_db_name};

CREATE DATABASE IF NOT EXISTS ${unified_db_name};

# AIRFLOW DATABASE 
CREATE DATABASE IF NOT EXISTS airflow;

# HOP Database
CREATE DATABASE IF NOT EXISTS hop;