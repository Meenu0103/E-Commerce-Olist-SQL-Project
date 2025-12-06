/*
    OLIST ORDERS – DATA CLEANING SCRIPT
    Dataset: olist_orders_dataset.csv
    Table: olist_orders
    Purpose: Validate timestamps, missing values, and logical consistency
*/


--TOTAL ROW COUNT 
SELECT COUNT(*) AS total_rows
FROM olist_orders;


-- NULL VALUE CHECKS (per column)
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS status_nulls,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS purchase_nulls,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS approved_nulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS carrier_date_nulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS delivered_date_nulls,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS estimated_date_nulls
FROM olist_orders;


/* Interpretation:
   - Missing order_approved_at: customer placed the order, but payment approval delayed.
   - Missing delivery dates: common for cancelled or undelivered orders.
   - Missing carrier date: shipment never handed to carrier.
*/


--CHECK FOR DUPLICATE order_id (Should NEVER happen)
SELECT 
    order_id, COUNT(*) AS occurrences
FROM olist_orders
GROUP BY order_id
HAVING COUNT(*) > 1;


--TIMESTAMP LOGIC CHECKS - These identify impossible or suspicious dates.

-- A. Approval date *before* purchase date → INVALID 
SELECT *
FROM olist_orders
WHERE order_approved_at < order_purchase_timestamp;

-- B. Customer delivery earlier than approval → INVALID 
SELECT *
FROM olist_orders
WHERE order_delivered_customer_date < order_approved_at;

-- C. Delivered AFTER estimated delivery → Late deliveries (valid insight) 
SELECT *
FROM olist_orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- D. Delivered BEFORE the carrier even received the package → INVALID 
SELECT *
FROM olist_orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;


-- STATUS CONSISTENCY CHECKS

-- Orders marked as “delivered” but missing delivered dates
SELECT *
FROM olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- Orders marked “canceled” but have delivery dates (impossible) 
SELECT *
FROM olist_orders
WHERE order_status = 'canceled'
  AND order_delivered_customer_date IS NOT NULL;


-- DELIVERY TIME ANALYSIS PREP (It's not cleaning, but useful)

/* Days taken from purchase → delivery */
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    (order_delivered_customer_date - order_purchase_timestamp) AS actual_delivery_days,
    (order_estimated_delivery_date - order_purchase_timestamp) AS estimated_delivery_days
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL;

