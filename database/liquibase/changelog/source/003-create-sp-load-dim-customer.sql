--liquibase formatted sql

--changeset vadivel:003-create-sp-load-dim-customer splitStatements:false

CREATE PROCEDURE bpaydb_unified_dev.sp_load_dim_customer()
BEGIN
    DECLARE v_load_time DATETIME DEFAULT CURRENT_TIMESTAMP;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    DROP TEMPORARY TABLE IF EXISTS tmp_customer;

    CREATE TEMPORARY TABLE tmp_customer AS
    SELECT
        cardholder_id,
        customer_name,
        email,
        mobile,
        city,
        state,
        loyalty_tier,
        created_date
    FROM bpaydb_replicated_dev.cardholders;

    -- Expire changed customer records
    UPDATE bpaydb_unified_dev.dim_customer d
    JOIN tmp_customer s
        ON d.cardholder_id = s.cardholder_id
    SET
        d.effective_to = v_load_time,
        d.current_flag = 'N'
    WHERE d.current_flag = 'Y'
      AND (
          NOT (d.customer_name <=> s.customer_name)
          OR NOT (d.email <=> s.email)
          OR NOT (d.mobile <=> s.mobile)
          OR NOT (d.city <=> s.city)
          OR NOT (d.state <=> s.state)
          OR NOT (d.loyalty_tier <=> s.loyalty_tier)
      );

    -- Insert new customers and changed customer versions
    INSERT INTO bpaydb_unified_dev.dim_customer (
        cardholder_id,
        customer_name,
        email,
        mobile,
        city,
        state,
        loyalty_tier,
        created_date,
        effective_from,
        effective_to,
        current_flag
    )
    SELECT
        s.cardholder_id,
        s.customer_name,
        s.email,
        s.mobile,
        s.city,
        s.state,
        s.loyalty_tier,
        s.created_date,
        v_load_time,
        '9999-12-31 23:59:59',
        'Y'
    FROM tmp_customer s
    LEFT JOIN bpaydb_unified_dev.dim_customer d
        ON d.cardholder_id = s.cardholder_id
       AND d.current_flag = 'Y'
    WHERE d.customer_key IS NULL;

    DROP TEMPORARY TABLE IF EXISTS tmp_customer;

    COMMIT;
END