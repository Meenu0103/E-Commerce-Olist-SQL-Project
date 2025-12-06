/*
    OLIST ORDER ITEMS – DATA CLEANING SCRIPT
    Dataset: olist_order_items_dataset.csv
    Table: olist_order_items
    Purpose: Validate product-level order details, shipping dates, and pricing integrity
*/


-- TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM olist_order_items;


-- NULL VALUE CHECKS
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS order_item_id_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS shipping_limit_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_nulls
FROM olist_order_items;


/*
 Interpretation:
 - NULL price or freight_value should not happen; flag for quality check.
 - Missing shipping_limit_date indicates missing SLA.
*/


-- CHECK FOR DUPLICATES (order_id + order_item_id must be UNIQUE)
SELECT 
    order_id, order_item_id, COUNT(*) AS occurrences
FROM olist_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- INVALID PRICE CHECKS

-- Zero or negative prices (should not exist)
SELECT *
FROM olist_order_items
WHERE price <= 0;

-- Zero or negative freight values
SELECT *
FROM olist_order_items
WHERE freight_value < 0;


-- SHIPPING LIMIT CONSISTENCY
-- shipping_limit_date should be AFTER order purchase date

SELECT oi.*, o.order_purchase_timestamp
FROM olist_order_items oi
JOIN olist_orders o 
on oi.order_id = o.order_id
WHERE oi.shipping_limit_date < o.order_purchase_timestamp;

-- PRICE vs FREIGHT sanity check
-- Freight should not exceed product price except rare cases
SELECT *
FROM olist_order_items
WHERE freight_value > price;


-- PRODUCT REPEAT PURCHASE CHECK
-- (Not bad data, but will be used for insights)

SELECT 
    product_id,
    COUNT(*) AS total_items_sold
FROM olist_order_items
GROUP BY product_id
ORDER BY total_items_sold DESC;


/* 
DATA QUALITY SUMMARY 
1. No NULL prices or freight values → Good data quality
2. No duplicate (order_id + order_item_id) combinations → Good
3. 4,124 rows where freight_value > price:
      - Legit scenario due to logistics cost > item cost
      - To be treated as outliers only in pricing visualizations
4. No negative prices or freight values → Good
*/
