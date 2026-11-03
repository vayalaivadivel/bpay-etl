--liquibase formatted sql

--changeset vadivel:004-update-dim-customer-scd2

ALTER TABLE bpaydb_unified_dev.dim_customer
    MODIFY current_flag CHAR(1) NOT NULL DEFAULT 'Y';

ALTER TABLE bpaydb_unified_dev.dim_customer
    ADD COLUMN current_customer_id INT
    GENERATED ALWAYS AS (
        CASE
            WHEN current_flag = 'Y' THEN cardholder_id
            ELSE NULL
        END
    ) STORED;

CREATE UNIQUE INDEX uk_customer_current
    ON bpaydb_unified_dev.dim_customer(current_customer_id);