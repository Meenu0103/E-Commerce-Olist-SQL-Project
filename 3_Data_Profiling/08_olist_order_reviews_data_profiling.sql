/* 
    OLIST ORDER REVIEWS – DATA PROFILING SCRIPT
    Dataset: olist_order_reviews_dataset.csv
    Table: olist_order_reviews
    Purpose: Validate review scores, timestamps, missing values,
             and logical relationships with orders.
*/

-- 1. TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM olist_order_reviews;


-- 2. NULL VALUE CHECKS
SELECT
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS review_id_nulls,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS score_nulls,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS message_nulls,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS creation_nulls,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS answer_nulls
FROM olist_order_reviews;

/* Interpretation:
   - Titles/messages being NULL is NORMAL (customers often leave no text).
   - Missing creation/answer timestamps = suspicious -> should be investigated.
*/



-- 3. DUPLICATE CHECK for review_id
SELECT review_id, COUNT(*) AS occurrences
FROM olist_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

/*
 Interpretation:
   - Each order should ideally have ONE review.
   - Duplicate reviews = noisy records.
   - We DO NOT delete them
*/



-- 4. VALIDATE REVIEW SCORE RANGE (must be 1 to 5)
SELECT *
FROM olist_order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;


-- 5. TIMESTAMP CONSISTENCY CHECKS

-- A. Review created BEFORE the order was placed -> INVALID
SELECT r.*, o.order_purchase_timestamp
FROM olist_order_reviews r
JOIN olist_orders o 
on r.order_id = o.order_id
WHERE r.review_creation_date < o.order_purchase_timestamp;


-- B. Review created BEFORE the product was delivered -> SUSPICIOUS
SELECT r.*, o.order_delivered_customer_date
FROM olist_order_reviews r
JOIN olist_orders o 
on r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND r.review_creation_date < o.order_delivered_customer_date;


-- C. Review answer timestamp BEFORE customer created review -> INVALID
SELECT *
FROM olist_order_reviews
WHERE review_answer_timestamp < review_creation_date;


-- 6. LENGTH CHECKS FOR COMMENTS
-- Extremely short reviews
SELECT *
FROM olist_order_reviews
WHERE review_comment_message IS NOT NULL
  AND LENGTH(review_comment_message) < 5;

-- Extremely long reviews (spam-like)
SELECT *
FROM olist_order_reviews
WHERE LENGTH(review_comment_message) > 500;



-- 7. MATCH REVIEWS WITH ORDERS (missing order_id problems)
SELECT *
FROM olist_order_reviews
WHERE order_id NOT IN (SELECT order_id FROM olist_orders);


/* 
DATA QUALITY SUMMARY (after checks)

- 789 duplicate review_id values found (expected, because customers may update reviews)
- 74 reviews created BEFORE the order date -> timestamp errors (flag only, do NOT delete)
- No missing mandatory fields found
*/
