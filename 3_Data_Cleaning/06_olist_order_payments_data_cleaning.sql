/* 
    OLIST ORDER PAYMENTS – DATA CLEANING SCRIPT
    Dataset: olist_order_payments_dataset.csv
    Table: olist_order_payments
    Purpose: Validate payment information, amounts, and logical consistency
*/


-- 1. TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM olist_order_payments;


-- 2. NULL VALUE CHECKS
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS payment_seq_nulls,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS payment_type_nulls,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS installments_nulls,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS payment_value_nulls
FROM olist_order_payments;


/*
 Interpretation:
 - payment_value should never be NULL.
 - payment_type must always exist (credit card, boleto, voucher, etc.).
*/



-- 3. DUPLICATE CHECKS - Combination (order_id + payment_sequential) must be UNIQUE
SELECT order_id, payment_sequential, COUNT(*) AS occurrences
FROM olist_order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;


-- 4. INVALID PAYMENT VALUES
-- Zero or negative payment amounts
SELECT *
FROM olist_order_payments
WHERE payment_value <= 0;


-- Very high payment values (optional outlier detection)
SELECT *
FROM olist_order_payments
WHERE payment_value > 5000;   -- threshold chosen for inspection



-- 5. INSTALLMENTS CHECK
-- Negative installments (invalid)
SELECT *
FROM olist_order_payments
WHERE payment_installments < 0;

-- Zero installments but payment_value > 0 → might indicate cash/boleto
SELECT *
FROM olist_order_payments
WHERE payment_installments = 0 AND payment_type NOT IN ('boleto', 'voucher', 'debit_card');


-- 6. PAYMENT TYPE QUALITY CHECK
-- List all payment types used
SELECT DISTINCT payment_type
FROM olist_order_payments;

-- Strange payment types (should not happen)
SELECT *
FROM olist_order_payments
WHERE payment_type NOT IN ('credit_card', 'boleto', 'voucher', 'debit_card', 'not_defined');


-- 7. MULTIPLE PAYMENTS PER ORDER CHECK
-- Some orders are paid in multiple transactions → VALID behavior
SELECT order_id, COUNT(*) AS num_payments, SUM(payment_value) AS total_paid
FROM olist_order_payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY num_payments DESC;

